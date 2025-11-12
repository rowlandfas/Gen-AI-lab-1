import os
import json
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views import View
from .models import Conversation, Message, UserContext

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", None)


class Index(View):
    """Simple class-based view for the home page or index."""
    def get(self, request):
        html_content = """
        <html>
            <head><title>Chatbot</title></head>
            <body>
                <h1>Welcome to the Chatbot</h1>
                <p>Use the API endpoint <code>/api/chat/</code> to send messages.</p>
            </body>
        </html>
        """
        return HttpResponse(html_content)


@csrf_exempt
def chat_api(request):
    # Simplest API: POST { user_id, message }
    if request.method != 'POST':
        return JsonResponse({'error': 'POST required'}, status=405)
    
    data = json.loads(request.body.decode('utf-8'))
    user_id = data.get('user_id', 'anonymous')
    text = data.get('message', '')
    
    if not text:
        return JsonResponse({'error': 'message required'}, status=400)

    # get or create conversation
    conv, _ = Conversation.objects.get_or_create(user_id=user_id)
    Message.objects.create(conversation=conv, role='user', text=text)

    # retrieve user context
    uctx, _ = UserContext.objects.get_or_create(user_id=user_id)
    context = uctx.context or {}

    # generate reply (OpenAI if configured, else fallback)
    reply = generate_reply(text, context)

    # save bot message
    Message.objects.create(conversation=conv, role='bot', text=reply)

    # update user context (store last message)
    context['last_user_message'] = text
    uctx.context = context
    uctx.save()

    # return reply and truncated conversation history
    recent = conv.messages.all().order_by('-timestamp')[:10]
    history = [{'role': m.role, 'text': m.text} for m in reversed(recent)]
    
    return JsonResponse({'reply': reply, 'history': history})


def generate_reply(user_text, context):
    """Return a reply string. Use OpenAI if API key present, else minimal fallback."""
    if OPENAI_API_KEY:
        try:
            import openai
            openai.api_key = OPENAI_API_KEY
            system = "You are a helpful assistant that remembers user context stored in JSON."
            messages = [
                {"role": "system", "content": system},
                {"role": "user", "content": f"Context: {json.dumps(context)}\nUser: {user_text}"}
            ]
            resp = openai.ChatCompletion.create(
                model='gpt-3.5-turbo',
                messages=messages,
                max_tokens=150
            )
            return resp.choices[0].message.content.strip()
        except Exception as e:
            return f"(AI error) Sorry, I couldn't reach the AI service: {e}"
    
    # fallback replies
    if 'hello' in user_text.lower():
        return "Hello! How can I help you today?"
    if '?' in user_text:
        return "That's an interesting question — tell me more."
    
    return "I stored that in your context. Tell me more or ask me a question."

from django.db import models


class Conversation(models.Model):
    user_id = models.CharField(max_length=200, db_index=True)  # could be session id, username, etc.
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Conversation {self.pk} ({self.user_id})"


class Message(models.Model):
    ROLE_CHOICES = (('user', 'user'), ('bot', 'bot'))
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages')
    role = models.CharField(max_length=10, choices=ROLE_CHOICES)
    text = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['timestamp']

    def __str__(self):
        return f"{self.role}: {self.text[:50]}"


class UserContext(models.Model):
    user_id = models.CharField(max_length=200, unique=True)
    context = models.JSONField(default=dict)  # ✅ built-in JSONField (correct)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Context for {self.user_id}"

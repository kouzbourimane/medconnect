from django.db import migrations
from django.utils import timezone


def _column_names(schema_editor):
    table = "app_message"
    with schema_editor.connection.cursor() as cursor:
        if schema_editor.connection.vendor == "sqlite":
            cursor.execute(f"PRAGMA table_info({table})")
            return {row[1] for row in cursor.fetchall()}

        cursor.execute(
            """
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = %s
            """,
            [table],
        )
        return {row[0] for row in cursor.fetchall()}


def ensure_message_created_at(apps, schema_editor):
    columns = _column_names(schema_editor)

    if "sent_at" in columns and "created_at" not in columns:
        schema_editor.execute(
            "ALTER TABLE app_message RENAME COLUMN sent_at TO created_at"
        )
        columns.remove("sent_at")
        columns.add("created_at")

    if "created_at" not in columns:
        schema_editor.execute(
            "ALTER TABLE app_message ADD COLUMN created_at timestamp with time zone"
        )
        now = timezone.now()
        if "read_at" in columns:
            schema_editor.execute(
                "UPDATE app_message SET created_at = COALESCE(read_at, %s) WHERE created_at IS NULL",
                [now],
            )
        else:
            schema_editor.execute(
                "UPDATE app_message SET created_at = %s WHERE created_at IS NULL",
                [now],
            )


class Migration(migrations.Migration):
    dependencies = [
        ("app", "0009_messageattachment"),
    ]

    operations = [
        migrations.RunPython(
            ensure_message_created_at,
            migrations.RunPython.noop,
        ),
    ]

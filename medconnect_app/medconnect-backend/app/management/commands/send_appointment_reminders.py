from datetime import timedelta

from django.core.management.base import BaseCommand
from django.utils import timezone

from app.models import Appointment, Notification


class Command(BaseCommand):
    help = "Envoie les rappels pour les rendez-vous confirmes dans les prochaines 24 heures."

    def add_arguments(self, parser):
        parser.add_argument(
            "--hours",
            type=int,
            default=24,
            help="Fenetre de rappel en heures. Par defaut: 24.",
        )

    def handle(self, *args, **options):
        now = timezone.now()
        reminder_until = now + timedelta(hours=options["hours"])

        appointments = Appointment.objects.select_related(
            "patient__user",
            "doctor__user",
        ).filter(
            status="CONFIRMED",
            reminder_sent=False,
            date__gt=now,
            date__lte=reminder_until,
        )

        count = 0
        for appointment in appointments:
            date_label = appointment.date.strftime("%Y-%m-%d a %H:%M")
            patient_message = (
                f"Rappel : vous avez un rendez-vous le {date_label} "
                f"avec Dr. {appointment.doctor.user.get_full_name()}."
            )
            doctor_message = (
                f"Rappel : rendez-vous le {date_label} "
                f"avec {appointment.patient.user.get_full_name()}."
            )

            Notification.objects.bulk_create(
                [
                    Notification(
                        user=appointment.patient.user,
                        title="Rappel de rendez-vous",
                        message=patient_message,
                        type="APPOINTMENT",
                    ),
                    Notification(
                        user=appointment.doctor.user,
                        title="Rappel de rendez-vous",
                        message=doctor_message,
                        type="APPOINTMENT",
                    ),
                ]
            )
            appointment.reminder_sent = True
            appointment.save(update_fields=["reminder_sent", "updated_at"])
            count += 1

        self.stdout.write(self.style.SUCCESS(f"{count} rappel(s) envoye(s)."))

# app/apps.py
from django.apps import AppConfig


class AppConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "app"

    def ready(self):
        # Django 4.2 + Python 3.14 breaks admin form rendering because
        # BaseContext.__copy__ uses copy(super()), which no longer produces
        # a writable duplicate. Patch it once at startup for local admin use.
        from django.template.context import BaseContext

        if getattr(BaseContext, "_medconnect_py314_patch", False):
            return

        def _safe_copy(self):
            duplicate = object.__new__(self.__class__)
            if hasattr(self, "__dict__"):
                duplicate.__dict__.update(self.__dict__)
            duplicate.dicts = self.dicts[:]
            return duplicate

        BaseContext.__copy__ = _safe_copy
        BaseContext._medconnect_py314_patch = True

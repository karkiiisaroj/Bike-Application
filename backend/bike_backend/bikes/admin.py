from django.contrib import admin
from django import forms
from django.urls import path, reverse
from django.shortcuts import render, redirect
from django.contrib import messages
from django.utils.html import format_html
from .models import Category, Bike, BikeColorVariant, BikeFrame


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'slug']
    prepopulated_fields = {'slug': ('name',)}


class BikeColorVariantInline(admin.TabularInline):
    model = BikeColorVariant
    extra = 1
    fields = ['name', 'tank_image', 'order', 'frame_link']
    readonly_fields = ['frame_link']

    def frame_link(self, obj):
        if not obj.pk:
            return '(save first)'
        url = reverse('admin:bikes_bikecolorvariant_upload_frames', args=[obj.pk])
        return format_html('<a href="{}">{} / 36 frames — upload/replace</a>', url, obj.frame_count)
    frame_link.short_description = 'Frames'


@admin.register(Bike)
class BikeAdmin(admin.ModelAdmin):
    list_display = ['name', 'category']
    list_filter = ['category']
    inlines = [BikeColorVariantInline]


class MultipleFileInput(forms.ClearableFileInput):
    allow_multiple_selected = True


class MultipleFileField(forms.FileField):
    def __init__(self, *args, **kwargs):
        kwargs.setdefault('widget', MultipleFileInput())
        super().__init__(*args, **kwargs)

    def clean(self, data, initial=None):
        single_file_clean = super().clean
        if isinstance(data, (list, tuple)):
            return [single_file_clean(d, initial) for d in data]
        return single_file_clean(data, initial)


class FrameUploadForm(forms.Form):
    images = MultipleFileField(
        help_text='Select all 36 frames at once. They will be numbered 1-36 in the '
                   'order your file picker lists them — name your files so they sort '
                   'correctly (e.g. frame_01.png, frame_02.png, … frame_36.png).',
    )


@admin.register(BikeColorVariant)
class BikeColorVariantAdmin(admin.ModelAdmin):
    list_display = ['bike', 'name', 'tank_image', 'frame_count']
    list_filter = ['bike']

    def get_urls(self):
        urls = super().get_urls()
        custom = [
            path(
                '<int:variant_id>/upload-frames/',
                self.admin_site.admin_view(self.upload_frames_view),
                name='bikes_bikecolorvariant_upload_frames',
            ),
        ]
        return custom + urls
    
    def upload_frames_view(self, request, variant_id):
        variant = BikeColorVariant.objects.get(pk=variant_id)

        if request.method == 'POST':
            form = FrameUploadForm(request.POST, request.FILES)
            files = request.FILES.getlist('images')

            if form.is_valid() and files:
                variant.frames.all().delete()

                for i, f in enumerate(files, start=1):
                    BikeFrame.objects.create(
                        variant=variant,
                        frame_number=i,
                        image=f
                    )

                messages.success(
                    request,
                    f'Uploaded {len(files)} frames for {variant}.'
                )

                return redirect(
                    reverse(
                        'admin:bikes_bikecolorvariant_change',
                        args=[variant.bike_id]
                    )
                )

            # If POST but no files / invalid form,
            # fall through and render the form with errors.

        else:
            form = FrameUploadForm()

        return render(
            request,
            'bikes/upload_frames.html',
            {
                'form': form,
                'variant': variant,
                'title': f'Upload Frames — {variant}',
            }
        )
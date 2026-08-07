from django.db import models


# Bike Category
class BikeCategory(models.Model):
    name = models.CharField(max_length=100)
    slug = models.SlugField(unique=True)
    image = models.ImageField(upload_to="categories/")
    description = models.TextField(blank=True)

    class Meta:
        ordering = ["name"]
        verbose_name = "Bike Category"
        verbose_name_plural = "Bike Categories"

    def __str__(self):
        return self.name

# Bike
class Bike(models.Model):
    category = models.ForeignKey(
        BikeCategory,
        on_delete=models.CASCADE,
        related_name="bikes"
    )

    name = models.CharField(max_length=100)
    slug = models.SlugField(unique=True)

    short_description = models.CharField(max_length=255)
    description = models.TextField()

    price = models.DecimalField(
        max_digits=12,
        decimal_places=2
    )

    hero_image = models.ImageField(
        upload_to="bikes/hero/"
    )

    is_available = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["name"]

    def __str__(self):
        return self.name

# Bike Gallery Images
class BikeImage(models.Model):

    IMAGE_TYPES = (
        ("front", "Front"),
        ("rear", "Rear"),
        ("left", "Left"),
        ("right", "Right"),
        ("top", "Top"),
        ("gallery", "Gallery"),
    )

    bike = models.ForeignKey(
        Bike,
        on_delete=models.CASCADE,
        related_name="images"
    )

    image = models.ImageField(
        upload_to="bikes/gallery/"
    )

    image_type = models.CharField(
        max_length=20,
        choices=IMAGE_TYPES,
        default="gallery"
    )

    display_order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ["display_order"]

    def __str__(self):
        return f"{self.bike.name} - {self.image_type}"


# Bike Colors
class BikeColor(models.Model):

    bike = models.ForeignKey(
        Bike,
        on_delete=models.CASCADE,
        related_name="colors"
    )

    name = models.CharField(max_length=100)

    color_code = models.CharField(
        max_length=7,
        help_text="HEX Color"
    )

    image = models.ImageField(
        upload_to="bikes/colors/"
    )

    class Meta:
        ordering = ["name"]
        unique_together = ("bike", "name")

    def __str__(self):
        return f"{self.bike.name} - {self.name}"


# 360 Viewer Frames
class BikeFrame(models.Model):

    color = models.ForeignKey(
        BikeColor,
        on_delete=models.CASCADE,
        related_name="frames"
    )

    frame_order = models.PositiveIntegerField()

    image = models.ImageField(
        upload_to="bikes/viewer360/"
    )

    class Meta:
        ordering = ["frame_order"]

    def __str__(self):
        return f"{self.color.bike.name} - Frame {self.frame_order}"


# Bike Specifications
class BikeSpecification(models.Model):

    bike = models.OneToOneField(
        Bike,
        on_delete=models.CASCADE,
        related_name="specification"
    )

    engine = models.CharField(max_length=100)

    displacement = models.CharField(max_length=50)

    max_power = models.CharField(max_length=50)

    max_torque = models.CharField(max_length=50)

    transmission = models.CharField(max_length=50)

    fuel_capacity = models.CharField(max_length=50)

    mileage = models.CharField(max_length=50)

    kerb_weight = models.CharField(max_length=50)

    seat_height = models.CharField(max_length=50)

    ground_clearance = models.CharField(max_length=50)

    wheelbase = models.CharField(max_length=50)

    braking = models.CharField(max_length=100)

    tyre_front = models.CharField(max_length=100)

    tyre_rear = models.CharField(max_length=100)

    def __str__(self):
        return self.bike.name

# Bike Features
class BikeFeature(models.Model):

    bike = models.ForeignKey(
        Bike,
        on_delete=models.CASCADE,
        related_name="features"
    )

    title = models.CharField(max_length=100)

    description = models.TextField()

    icon = models.ImageField(
        upload_to="bikes/features/"
    )

    class Meta:
        ordering = ["title"]

    def __str__(self):
        return f"{self.bike.name} - {self.title}"
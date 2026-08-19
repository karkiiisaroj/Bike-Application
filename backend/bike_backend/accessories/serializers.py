from django.db import transaction
from rest_framework import serializers

from .models import Accessory, Order, OrderItem


class AccessoryListSerializer(serializers.ModelSerializer):
    """Lighter shape used for the grid/browse views."""

    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Accessory
        fields = ["id", "slug", "name", "price", "category", "image_url", "in_stock"]

    def get_image_url(self, obj):
        if not obj.image:
            return None
        request = self.context.get("request")
        return request.build_absolute_uri(obj.image.url) if request else obj.image.url


class AccessoryDetailSerializer(AccessoryListSerializer):
    compatible_bikes = serializers.SerializerMethodField()

    class Meta(AccessoryListSerializer.Meta):
        fields = AccessoryListSerializer.Meta.fields + [
            "description",
            "stock",
            "compatible_bikes",
        ]

    def get_compatible_bikes(self, obj):
        return list(obj.fitments.values_list("bike_name", flat=True))


class OrderItemInputSerializer(serializers.Serializer):
    accessory_id = serializers.IntegerField()
    quantity = serializers.IntegerField(min_value=1)


class OrderItemSerializer(serializers.ModelSerializer):
    accessory_name = serializers.CharField(source="accessory.name", read_only=True)

    class Meta:
        model = OrderItem
        fields = ["accessory", "accessory_name", "quantity", "unit_price", "subtotal"]


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)

    class Meta:
        model = Order
        fields = [
            "id",
            "order_number",
            "customer_name",
            "phone",
            "email",
            "address",
            "city",
            "payment_method",
            "status",
            "total_price",
            "created_at",
            "items",
        ]
        read_only_fields = ["order_number", "status", "total_price", "created_at"]


class CreateOrderSerializer(serializers.Serializer):
    """
    Accepts customer + delivery details and a cart of
    {accessory_id, quantity} pairs. Prices are taken from the current
    Accessory records server-side (never trusted from the client),
    stock is decremented atomically, and a human-friendly order number
    is generated for tracking.
    """

    customer_name = serializers.CharField(max_length=120)
    phone = serializers.CharField(max_length=20)
    email = serializers.EmailField(required=False, allow_blank=True)
    address = serializers.CharField(max_length=255)
    city = serializers.CharField(max_length=80)
    payment_method = serializers.ChoiceField(
        choices=Order.PaymentMethod.choices, default=Order.PaymentMethod.COD
    )
    items = OrderItemInputSerializer(many=True)

    def validate_items(self, items):
        if not items:
            raise serializers.ValidationError("Order must contain at least one item.")
        return items

    @transaction.atomic
    def create(self, validated_data):
        items_data = validated_data.pop("items")
        request = self.context.get("request")

        order = Order.objects.create(
            user=request.user if request and request.user.is_authenticated else None,
            **validated_data,
        )

        total = 0
        for item in items_data:
            try:
                accessory = Accessory.objects.select_for_update().get(
                    pk=item["accessory_id"], is_active=True
                )
            except Accessory.DoesNotExist:
                raise serializers.ValidationError(
                    f"Accessory {item['accessory_id']} is not available."
                )

            qty = item["quantity"]
            if accessory.stock < qty:
                raise serializers.ValidationError(
                    f"Only {accessory.stock} left in stock for {accessory.name}."
                )

            accessory.stock -= qty
            accessory.save(update_fields=["stock"])

            OrderItem.objects.create(
                order=order,
                accessory=accessory,
                quantity=qty,
                unit_price=accessory.price,
            )
            total += accessory.price * qty

        order.total_price = total
        order.save(update_fields=["total_price"])
        return order
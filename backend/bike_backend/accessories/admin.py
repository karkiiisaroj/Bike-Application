from django.contrib import admin

from .models import Accessory, AccessoryFitment, Order, OrderItem


class AccessoryFitmentInline(admin.TabularInline):
    model = AccessoryFitment
    extra = 1


@admin.register(Accessory)
class AccessoryAdmin(admin.ModelAdmin):
    list_display = ["name", "category", "price", "stock", "is_active"]
    list_filter = ["category", "is_active"]
    search_fields = ["name"]
    prepopulated_fields = {"slug": ("name",)}
    inlines = [AccessoryFitmentInline]


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields = ["accessory", "quantity", "unit_price"]
    can_delete = False


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = [
        "order_number",
        "customer_name",
        "phone",
        "status",
        "payment_method",
        "total_price",
        "created_at",
    ]
    list_filter = ["status", "payment_method"]
    search_fields = ["order_number", "customer_name", "phone"]
    readonly_fields = ["order_number", "total_price", "created_at"]
    inlines = [OrderItemInline]
# msb_store

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:


For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,

## Product Seller Fields

Each document in the Firestore `products` collection can belong to a different seller. Add these fields when creating a product:

# msb_store

## Firebase Product Fields

When manually adding a product to the Firestore `products` collection, add the seller name as `shopName`:

```json
{
	"name": "Phone Tripod",
	"description": "Product description",
	"image": "https://example.com/product-image.jpg",
	"price": 1450,
	"shopName": "YU Shop",
	"sellerId": "yu_shop"
}
```

The product details screen displays `Sold by: YU Shop`. `sellerId` is recommended so each shop gets its own seller chat. If it is omitted, the app uses `shopName` as the fallback identity.

Seller chats are combined per buyer and seller at `seller_chats/{buyerId}_{sellerId}/messages`. Each message keeps `productId` and `productName`, so one seller can answer questions about many products in the same chat.

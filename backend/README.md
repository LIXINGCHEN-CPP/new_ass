# Grocery Store Backend API

Node.js/Express backend API for the Grocery Store Flutter application.

## Features
- REST API endpoints for categories, products, bundles, and orders
- MongoDB Atlas integration
- CORS enabled for Flutter app
- Health check endpoint
- Error handling and logging

## Backend server has been deployment with Render.com

## If you want develop locally, use following cmd
```bash
npm install
npm run dev
```

## Some example API Endpoints of backend
- `GET /health` - Health check
- `GET /api/categories` - Get all categories
- `GET /api/products` - Get all products
- `GET /api/bundles` - Get all bundles
- `POST /api/orders` - Create new order

## Quick Start

### The backend service has been deployed
```bash
flutter run
```

## Testing API

### Using curl(locally)
```bash
# Test server
curl http://localhost:3000/health

# Get categories
curl http://localhost:3000/api/categories

# Get products
curl http://localhost:3000/api/products

# Get new products
curl "http://localhost:3000/api/products?isNew=true"

# Search products
curl http://localhost:3000/api/products/search/ice
```

### Using browser
Direct access: `http://localhost:3000/api/categories`

## Important Notes

1. Ensure Node.js version >= 14
2. Ensure MongoDB Atlas database is initialized with data
3. Ensure network access to MongoDB Atlas
4. Modify security configuration for production

## Logging
Server logs will display:
- Database connection status
- API request records
- Error information
- Performance statistics 

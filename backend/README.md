# Grocery Store Backend API

Node.js backend service that connects to MongoDB Atlas database and provides API services for Flutter applications.

## Quick Start

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Database Connection
Edit the `config.js` file to ensure the MongoDB connection string is correct:
```javascript
mongodbUri: 'mongodb+srv://username:password@cluster0.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0'
```

### 3. Start Development Server
```bash
npm run dev
```

### 4. Start Production Server
```bash
npm start
```

## API Endpoints

### Basic Information
- **Server Address**: `http://localhost:3000`
- **API Prefix**: `/api`
- **Response Format**: JSON

### Endpoint List

#### 1. Health Check
```
GET /health
```

#### 2. Categories
```
GET /api/categories          # Get all categories
GET /api/categories/:id      # Get specific category
```

#### 3. Products
```
GET /api/products            # Get all products
GET /api/products/:id        # Get specific product
GET /api/products/search/:term  # Search products
```

**Query Parameters**:
- `categoryId`: Filter by category
- `isNew`: Filter new products (true/false)
- `isPopular`: Filter popular products (true/false)
- `isActive`: Filter active products (true/false)

#### 4. Bundles
```
GET /api/bundles             # Get all bundles
GET /api/bundles/:id         # Get specific bundle
```

**Query Parameters**:
- `categoryId`: Filter by category
- `isPopular`: Filter popular bundles (true/false)
- `isActive`: Filter active bundles (true/false)

## Response Format

### Success Response
```json
{
  "success": true,
  "data": [...],
  "count": 10
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error"
}
```

## Environment Configuration

### Port Configuration
Default port: `3000`
Can be modified via environment variable `PORT`

### CORS Configuration
Default allows all origins, modify `corsOrigin` in `config.js` for production

## Dependencies

- **express**: Web framework
- **mongodb**: MongoDB driver
- **cors**: Cross-origin resource sharing
- **helmet**: Security middleware
- **morgan**: Request logging
- **express-rate-limit**: Request rate limiting

## Testing API

### Using curl
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
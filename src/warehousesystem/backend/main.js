const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();


const sequelize = require('./config/db')
const CreateTables = require('./config/setup');

const UserRoutes = require('./router/userRoutes');
const ProductCategoriesRoutes = require('./router/productCategoriesRoutes');
const ProductRoutes = require('./router/productRoutes');

dotenv.config();
const app = express()
const PORT = process.env.PORT || 5000;

app.use(cors({
    origin: true,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
}));
app.use(express.json());

app.use('/api/user', UserRoutes);
app.use('/api/category', ProductCategoriesRoutes)
app.use('/api/product', ProductRoutes)

async function initializeApp() { 
    try{
    await CreateTables(sequelize ) 

  app.listen(PORT, () => console.log(`Server running on port ${PORT}`)); 
} catch (error) {
console.error('Error initializeApp', error.message)
}
}

 initializeApp()
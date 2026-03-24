const express = require('express');
const router = express.Router();
const ProductsController = require('../controllers/productsController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/', authMiddleware, ProductsController.CreateProduct);

router.get('/:name',   ProductsController.GetProductByName);
router.get('/products/all',  ProductsController.GetProductsAll)
router.put('/update/:product_id',  authMiddleware, ProductsController.UpdateProduct);
router.delete('/delete/:product_id', authMiddleware, ProductsController.DeleteProduct);

module.exports = router;
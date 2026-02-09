const express = require('express');
const router = express.Router();
const ProductCategoriesController = require('../controllers/productCategoriesController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/', authMiddleware, ProductCategoriesController.CreateCategory);
router.get('/categories/all', authMiddleware, ProductCategoriesController.GetCategoriesAll)
router.get('/:name', authMiddleware, ProductCategoriesController.GetCategoryByName)
router.put('/update/:category_id', authMiddleware, ProductCategoriesController.UpdateCategory)
router.delete('/delete/:category_id', authMiddleware, ProductCategoriesController.DeleteCategory);

module.exports = router;
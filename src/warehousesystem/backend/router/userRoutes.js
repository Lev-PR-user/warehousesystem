const express = require('express');
const router = express.Router();
const UserController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/register', UserController.register);
router.post('/login', UserController.login);

router.get('/profile', authMiddleware, UserController.Profile);
router.put('/update', authMiddleware, UserController.UpdateProfile);
router.delete('/delete', authMiddleware, UserController.DeleteProfile);

module.exports = router;
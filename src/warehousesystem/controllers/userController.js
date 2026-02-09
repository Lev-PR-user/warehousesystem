const UserService = require('../service/userService');

class UserController {
    async register(req, res) {
        try {
            const user = await UserService.register(req.body);
            res.status(201).json(user);
        } catch (error) {
            res.status(400).json({ message: error.message });
        }
    };

    async login(req, res) {
        try {
            const result = await UserService.login(req.body);
            res.status(200).json(result);
        } catch (error) {
            res.status(400).json({ message: error.message });
        }
    };

    async Profile(req, res){
        try{
            const user_id = req.user.user_id;
            const result = await UserService.Profile(user_id);
            res.status(200).json(result);
        } catch (error){
            res.status(400).json({ message: error.message });
        }
    };


    async UpdateProfile(req, res){
         try{
            const user_id = req.user.user_id;
            const result = await UserService.UpdateProfile(user_id, req.body);
            res.status(200).json(result);
        } catch (error){
            res.status(400).json({ message: error.message });
        }
    };

    async DeleteProfile(req, res){
         try{
            const user_id = req.user.user_id;
            const result = await UserService.DeleteProfile(user_id);
            res.status(200).json(result);
        } catch (error){
            res.status(400).json({ message: error.message });
        }
    };
};

module.exports = new UserController();
const UserValidator = require(`../validators/userValidator`);
const UsersRepository = require(`../repository/userRepository`);
const jwt = require('jsonwebtoken'); 

class UserService{

    async register(UsersData){
        UserValidator.ValidatorRegistrationData(UsersData);

        const existinguser = await UsersRepository.FindUsers(UsersData.email);
        if (existinguser) {
                throw new Error('User already exists');
            };

        const hashedPassword = await UserValidator.hashPassword(UsersData.hashed_password);
            UsersData.hashed_password = hashedPassword;

        const user = await UsersRepository.CreateUser({
            phone: UsersData.phone,
            email: UsersData.email,
            hashed_password: hashedPassword,
            avatar_url: UsersData.avatar_url,
            login: UsersData.login 
        });

        const token = jwt.sign(
            { 
                user_id: user.user_id,
                email: user.email,
                role: user.role 
            },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );



        return {
            token: token,
            user: {
                user_id: user.user_id,
                phone: user.phone,
                email: user.email,
                login: user.login, 
            }
        }
    };

    async login(loginData){
        UserValidator.validateLoginData(loginData);

        const user = await UsersRepository.FindUsers(loginData.email);
            if (!user) {
                throw new Error('User not found');
            };

            const isValidPassword = await UserValidator.validatePassword(
                loginData.hashed_password, 
                user.hashed_password
            );

             if (!isValidPassword) {
                throw new Error('Invalid password');
            }
        const token = jwt.sign(
            { 
                user_id: user.user_id,
                email: user.email,
                role: user.role 
            },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );


            return {
                token: token,
                user: {
                    user_id: user.user_id, 
                    phone: user.phone,
                    email: user.email,
                    role: user.role
                }
             }
    }
    async Profile(user_id){

        UserValidator.validateProfile({ user_id });

        const user = await UsersRepository.findById(user_id)
        if(!user){
            throw new Error('User not found')
        }

        return {
            user: {
                user_id: user.user_id,
                login: user.login,
                phone: user.phone,
                email: user.email,
                role: user.role
            }
        }
    }
    async UpdateProfile(user_id, updateData){
        UserValidator.validateProfile({ user_id });

        const user = await UsersRepository.findById(user_id)
        if(!user){
            throw new Error('User not found')
        }

        const updatedUser = await UsersRepository.UpdateProfile(user_id, updateData);

        return {
            user: {
                user_id: user.user_id,
                login: user.login,
                phone: updatedUser.phone,
                email: updatedUser.email,
                role: updatedUser.role
            }
        }
    }
    async DeleteProfile(user_id){

         UserValidator.validateProfile({ user_id });

        const user = await UsersRepository.findById(user_id)
        if(!user){
            throw new Error('User not found')
        }

        await UsersRepository.DeleteProfile(user_id);

        return {
            message: 'User deleted successfully'
        };
    }
}

module.exports = new UserService();
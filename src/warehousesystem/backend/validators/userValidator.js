const bcrypt = require('bcryptjs');

class UserValidator {

    static validateemail(email){
        const emailRegex = /^[^\s@]+@(gmail\.com)$/;
        return emailRegex.test(email);
    };

    static ValidatorRegistrationData(UsersData){
        const { phone, email, hashed_password, login } = UsersData;

        if (!phone || !email || !hashed_password || !login){
            throw new Error(`All fields are required`);
        };

        if(!this.validateemail(email)){
            throw new Error(`Invalid email domain`);
        };

        if(hashed_password.length < 6){
            throw new Error(`Password must be a least 6 characters long'`)
        };

        if(login.length < 3){
            throw new Error(`Login must be at least 3 characters long`)
        };
        return true;
    };


    static async validatePassword(hashed_password, hash) {
        return await bcrypt.compare(hashed_password, hash);
    };

    static async hashPassword(hashed_password) {
        const salt = await bcrypt.genSalt(10);
        return await bcrypt.hash(hashed_password, salt);
    };

    static validateLoginData(LoginData) {
        const { email, hashed_password } = LoginData;
        
        if (!email|| !hashed_password) {
            throw new Error('Email and password are required');
        };

        return true;
    };

    static validateProfile(ProfileData){
        const { user_id } = ProfileData;

        if(!user_id){
            throw new Error('User id not found')
        };

        return true;
    };

    static validateUpdateData(updateData) {
    const { phone, email } = updateData;
    
    if (email && !this.validateemail(email)) {
        throw new Error('Invalid email format');
    };
    
    if (phone && !this.validatePhone(phone)) {
        throw new Error('Invalid phone format');
    };
    
        return true;
    };
};

module.exports = UserValidator;
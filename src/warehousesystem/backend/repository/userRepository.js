const sequelize  = require(`../config/db`);

class UserRepository{

    async FindUsers(email){
       const result = await sequelize.models.users.findOne({
        where: {email}
       });
       return result;
    };

    async CreateUser(UserData){
        const { phone, email, hashed_password, avatar_url, login  } = UserData;

        const result = await sequelize.models.users.create({
            phone,
            email,
            hashed_password,
            avatar_url,
            login 
        });
        return result;
    };

    async findById(user_id){

        const result = await sequelize.models.users.findOne({
            where: { user_id }
        });
        return result;
    };

    async UpdateProfile(user_id, updateData){
        const result = await sequelize.models.users.update(updateData, {
            where: { user_id },
            returning: true
        });
        return result[1][0];
    };

    async DeleteProfile(user_id){
        const result = await sequelize.models.users.destroy({
            where: {user_id}
        });
        return result;
    };
}

module.exports = new UserRepository();
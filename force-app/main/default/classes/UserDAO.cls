public class UserDAO {

    public static List<User> getLegalUsers(){
        return [SELECT ID FROM User WHERE PRofile.Name like '%legal%'];
    }
}
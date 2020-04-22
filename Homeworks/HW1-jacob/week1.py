# week1.py

def passwordEval(password_dict,username,password):
    """Checks if username/password are in the dict"""
    
    # make password lowercase
    password = password.lower()
    
    # assumes the dict passwords is accessible outside of function
    if username in password_dict.keys():
        if password_dict[username] == password:
            print('Username and password accepted!')
        
    else:
        print('Username/password not found!')
    



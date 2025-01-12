#!bin/bash
 mountpoint -q $HOME/workspace || sudo mount -t cifs //NUC9/workspace ~/workspace -o username=Yaoyuan,password=luzi@8tw,uid=$(id -u),gid=$(id -g),vers=3.0

### The windows system need set the privilege to create symbolic link (when python create virtual environment)
# 1. Open the Local Group Policy Editor (gpedit.msc)
# 2. Computer Configuration -> Windows Settings -> Security Settings -> Local Policies -> User Rights Assignment
# 3. Look for the policy "Create symbolic links"
# 4. Add the users or groups who should have this permission.

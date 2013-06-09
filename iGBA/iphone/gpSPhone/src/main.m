/*

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; version 2
 of the License.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#import <UIKit/UIKit.h>
#import "gpSPhoneApp.h"
#import "JoyPad.h"

unsigned char main_path[512];

void ChangeWorkingDirectory(char *exe)
{
  char *s = strrchr(exe, '/');
  if (s != NULL) {
    *s = '\0';
    chdir(exe);
    *s = '/';
  }
}

int main(int argc, char **argv)
{
    @autoreleasepool {
        ChangeWorkingDirectory(argv[0]);
        getcwd(main_path, 512);
        Init_joypad();
        int ret = UIApplicationMain(argc, argv, nil, NSStringFromClass([gpSPhoneApp class]));
        End_joypad();
        return ret;
    }
}
# RaidSettings

## Usage

Because of server rate limiting features, doing too many operations at the same time will cause a disconnect. Batch size is currently 5 by default. Because of this, you will need to repeat certain actions to complete organization.

1. Invite one other person and convert to raid group
2. Load the desired profile, for example
   * `/rs load swp`
   * `/rs load za`
3. Let RaidSettings invite up characters on the roster
   * `/rs invite`
4. Sort characters into their defined groups
   * `/rs sort`
5. Move mismatched characters into group 6-8
   * `/rs clean`
6. Repeat steps 3-5 until roster is complete
7. Promote defined characters
   * `/rs promote`

### Initial setup

The easiest way to setup your first raid is to do it normally then save the profile for later.

1. Invite your desired roster
2. Setup raid groups with Blizzard UI
3. Promote all neccessary characters manually
4. Save the profile for later, for example
   * `/rs save swp`
   * `/rs save za`

## Commands

* `/rs sort` - Sort raid group
* `/rs clean` - Move improper assignments to g6-8
* `/rs promote` - Promote assistants
* `/rs reset` - Reset profiles to default
* `/rs save profile` - Save profile
* `/rs load profile` - Load profile
* `/rs delete profile` - Delete profile
* `/rs list` - List profiles
* `/rs perf` - Toggle performance tweaks
* `/rs invite` - Invite current profile's roster
* `/rs batch N` - Set batch size to N
* `/rs add character:group` - Adds character to group roster
* `/rs remove character` - Removes character from group roster

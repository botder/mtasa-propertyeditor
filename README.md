# Property Editor
(CE)GUI property editor resource for the Multi Theft Auto: San Andreas multiplayer.

**Note:** Don't use this tool on a production server, because for example any button, which is disabled if you shouldn't have access to a certain feature, can be re-enabled by this tool.

## How to use
1. Add the resource to your server
2. Give the developers the ACL permission to use `command.propertyeditor`
3. Refresh the server and start `propertyeditor`
4. Type `/propertyeditor` to show the selection
5. Select a GUI element on your screen with 'right click'
6. Edit the properties of the selected element

## Requirements
- Players require the ACL permission for `command.propertyeditor`

## Screenshots
### Selector
![The selector shows the resource, type and text of the currently cursor-hovered element](.github/selector.png)

### Editor
![This is the main property editor window, where you can edit every supported property](.github/editor.png)

### Element tree
![If you can't select a certain GUI element, then you can always fall back to this little helper window to select the element from a list of all elements](.github/element-tree.png)

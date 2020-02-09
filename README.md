# icode-custom-plugin-example
This repository contains an example of how to develop a plugin to extend i-Code CNES features.

### Summary
* [Quick start](#quick-start)
* [Compiling the example](#compiling-the-example)
* [Install your custom plugin](#install-your-custom-plugin)
* [Available extension points](#available-extension-points)
* [Developer guide](#developer-guide)
* [Merging your custom plugin to official i-Code core feature](#merging-your-custom-plugin-to-official-i-code-core-feature)

### Quick start
If you are interested in developing a new plugin for i-Code analyzer, just download this example project.
```
git clone https://github.com/lequal/icode-custom-plugin-example
``` 
Then modify it to rule your checks.

This README contains some tips to develop easily new plugins, i-Code allow to develop plugin with very few class implementation to let you concentrate on the fundamental algorithm.

### Compiling the example
It is as simple as this lines:
```
mvn clean install
```

### Install your custom plugin
Install your custom plugin by copying it to the `<ICODE_HOME>/plugins` directory.

If the plugin contains a new language, you should see it by typing:
```
icode -l
```

If the plugin contains a new checker, you should see it by typing:
```
icode -c
```

### Available extension points
- `ILanguage`: This interface must be implemented to add a new supported language. The language of each file is determined through the file extension.
- `AbstractChecker`: This abstract class must be overridden to define new checkers to run on files with the correct extension.
- `CheckersDefinition`: This abstract class must be overridden to include new checkers and their metadata in your custom plugin.

### Developer guide
We provide a guide for developers who wonder how to implement their own checker easily: just follow [this link to our wiki](../../wiki/Developer-guide).

### Merging your custom plugin to official i-Code core feature
You have developed a new relevant checker and you want it to be integrated in i-Code core feature? So you are at the good place!

You can simply open a new pull request on https://github.com/lequal/i-CodeCNES and ensure you comply the following points:
- your plugin is compliant with the format of the other plugins
- your plugin demonstrate a high level of quality through SonarCloud analysis
- your plugin is provided with pertinent tests
- your pull request details what are the new/enhanced checks you proposed
- you are kind and ready to help our community :)

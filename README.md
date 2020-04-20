
# react-native-native-ciesdk

## Getting started

`$ npm install react-native-native-ciesdk --save`

### Mostly automatic installation

`$ react-native link react-native-native-ciesdk`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-native-ciesdk` and add `RNNativeCiesdk.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNNativeCiesdk.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNNativeCiesdkPackage;` to the imports at the top of the file
  - Add `new RNNativeCiesdkPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-native-ciesdk'
  	project(':react-native-native-ciesdk').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-native-ciesdk/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-native-ciesdk')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNNativeCiesdk.sln` in `node_modules/react-native-native-ciesdk/windows/RNNativeCiesdk.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Native.Ciesdk.RNNativeCiesdk;` to the usings at the top of the file
  - Add `new RNNativeCiesdkPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNNativeCiesdk from 'react-native-native-ciesdk';

// TODO: What to do with the module?
RNNativeCiesdk;
```
  
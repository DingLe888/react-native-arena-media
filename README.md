
# react-native-arena-media

## Getting started

`$ npm install react-native-arena-media --save`

### Mostly automatic installation

`$ react-native link react-native-arena-media`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-arena-media` and add `RNArenaMedia.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNArenaMedia.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.arena.media.RNArenaMediaPackage;` to the imports at the top of the file
  - Add `new RNArenaMediaPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-arena-media'
  	project(':react-native-arena-media').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-arena-media/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-arena-media')
  	```


## Usage
```javascript
import RNArenaMedia from 'react-native-arena-media';

<!--扫描二维码-->
RNArenaMedia.scanQRCode({}).then((value)=>{

      <!--value 为二维码扫描结果-->
    },(error)=>{
      <!--error 为二维码扫描报错信息-->

    })
```
  
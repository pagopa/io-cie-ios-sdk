import React, { Component } from 'react'
import { View, Text, Button } from 'react-native'
import { NativeModules } from 'react-native';

export default class App extends Component {
  state = {
    textValue: 'Change me'
  }

  onPress = () => {
    
    var ciesdk = NativeModules.CieModule;
      
    ciesdk.isNFCEnabled((value) => {
        if (value) {
          console.debug('nfc enabled');
        } else {
          console.debug('nfc not enabled');
        }
    });
      
    ciesdk.setPIN('11223344');
      
    ciesdk.setAuthenticationUrl('https://idppn-ipzs.fbk.eu/idp/erroreQr.jsp?opId=_bac67ee962bcae73318f5b634376c8bc&opType=login&SPName=FBK Test&IdPName=https://idppn-ipzs.fbk.eu/idp/&userId=CA00000AA&opText=FBK Test chiede di accedere ai servizi on-line &SPLogo=https://sp-ipzs-ssl.fbk.eu/img/sp.png');
    
    ciesdk.start((response) => {
        this.setState({
          textValue: response
        })
    });
  }

  render() {
    return (
      <View style={{paddingTop: 100}}>
        <Text>{this.state.textValue}</Text>
        <Button title="Change Text" onPress={this.onPress} />
      </View>
    )
  }
}

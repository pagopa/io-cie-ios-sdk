//
//  CIEIDSdk.swift
//  NFCTest
//

import UIKit
import CoreNFC

extension URL {
    var queryParameters: QueryParameters { return QueryParameters(url: self) }
}

class QueryParameters {
    let queryItems: [URLQueryItem]
    init(url: URL?) {
        queryItems = URLComponents(string: url?.absoluteString ?? "")?.queryItems ?? []
        print(queryItems)
    }
    subscript(name: String) -> String? {
        return queryItems.first(where: { $0.name == name })?.value
    }
}

struct Constants {
    static let KEY_VALUE = "value"
    static let KEY_AUTHN_REQUEST_STRING = "authnRequestString"
    static let KEY_NAME = "name"
    static let KEY_NEXT_UTL = "nextUrl"
    static let KEY_OP_TEXT = "OpText"
    static let KEY_LOGO = "imgUrl"
    static let generaCodice = "generaCodice"
    static let authnRequest = "authnRequest"
    static let BASE_URL_IDP = "https://idserver.servizicie.interno.gov.it/idp/Authn/SSL/Login2"
    //PRODUZIONE
    //"https://idserver.servizicie.interno.gov.it/idp/"
    //COLLAUDO
    //"https://idserver.servizicie.interno.gov.it:8443/idp/"
}
@available(iOS 13.0, *)
@objc(CIEIDSdk)
public class CIEIDSdk : NSObject, NFCTagReaderSessionDelegate {
    
    private var readerSession: NFCTagReaderSession?
    private var cieTag: NFCISO7816Tag?
    private var cieTagReader : CIETagReader?
    private var completedHandler: ((String?, String?)->())!
    
    private var url : String?
    private var pin : String?    
    
    @objc public var attemptsLeft : Int;
    
    override public init( ) {
        
        
        attemptsLeft = 3
        cieTag = nil
        cieTagReader = nil
        url = nil
        
        super.init()
    }
    
    private func start(completed: @escaping (String?, String?)->() ) {
        self.completedHandler = completed
        
        guard NFCTagReaderSession.readingAvailable else {
            completedHandler( ErrorHelper.TAG_ERROR_NFC_NOT_SUPPORTED, nil)//TagError(errorDescription: "NFCNotSupported"))
            return
        }
        
        Log.debug( "authenticate" )
        
        if NFCTagReaderSession.readingAvailable {
            Log.debug( "readingAvailable" )
            readerSession = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: nil)
            readerSession?.alertMessage = "Tieni la tua carta d’identità elettronica sul retro dell’iPhone, nella parte in alto."
            readerSession?.begin()
        }
    }
    
    @objc
    public func post(url: String, pin: String, completed: @escaping (String?, String?)->() ) {
           self.pin = pin
           self.url = url

           self.start(completed: completed)
    }
    
    @objc
    public func hasNFCFeature() -> Bool {
        return NFCTagReaderSession.readingAvailable
    }

    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        Log.debug( "tagReaderSessionDidBecomeActive" )
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        Log.debug( "tagReaderSession:didInvalidateWithError - \(error)" )
        if(self.readerSession != nil)
        {
            let nfcError = error as! NFCReaderError
            let errorMessage = ErrorHelper.nativeError(errorMessage: ErrorHelper.decodeError(error:UInt16(nfcError.errorCode)))
            self.readerSession?.invalidate(errorMessage:errorMessage)
            self.completedHandler(ErrorHelper.TAG_ERROR_SESSION_INVALIDATED, nil)
        }
        
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        Log.debug( "tagReaderSession:didDetect - \(tags[0])" )
        if tags.count > 1 {
            session.alertMessage = "More than 1 tags was found. Please present only 1 tag."
            return
        }
        
        let tag = tags.first!
        
        switch tags.first! {
        case let .iso7816(tag):
            cieTag = tag
        default:
            //self.readerSession = nil
            self.readerSession?.invalidate(errorMessage: "La carta utilizzata non sembra essere una Carta di Identità Elettronica (CIE).")
            self.completedHandler("ON_TAG_DISCOVERED_NOT_CIE", nil)
            return
        }
        
        // Connect to tag
        session.connect(to: tag) { [unowned self] (error: Error?) in
            if error != nil {
                let  session = self.readerSession
                session?.invalidate(errorMessage: "Hai rimosso la carta troppo presto.")
                // self.readerSession = nil
                self.completedHandler("ON_TAG_LOST", nil)
                return
            }
            
            self.readerSession?.alertMessage = "Lettura in corso, tieni ferma la carta ancora per qualche secondo..."
            self.cieTagReader = CIETagReader(tag:self.cieTag!)
            self.startReading( )
        }
    }

    func startReading()
    {
        //ATR is not available on IOS
        // print("iso7816Tag historical bytes \(String(data: self.passportTag!.historicalBytes!, encoding: String.Encoding.utf8))")
        //
        // print("iso7816Tag identifier \(String(data: self.passportTag!.identifier, encoding: String.Encoding.utf8))")
        //
                      
        
        let url1 = URL(string: self.url!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        let value = url1!.queryParameters[Constants.KEY_VALUE]!
        let name = url1!.queryParameters[Constants.KEY_NAME]!
        let authnRequest = url1!.queryParameters[Constants.KEY_AUTHN_REQUEST_STRING]!
        let nextUrl = url1!.queryParameters[Constants.KEY_NEXT_UTL]!
//        let opText = url1!.queryParameters[Constants.KEY_OP_TEXT]!
//        let logo = url1?.queryParameters[Constants.KEY_LOGO]!

        let params = "\(value)=\(name)&\(Constants.authnRequest)=\(authnRequest)&\(Constants.generaCodice)=1"
        
        self.cieTagReader?.post(url: Constants.BASE_URL_IDP, pin: self.pin!, data: params, completed: { (data, error) in
          
            let  session = self.readerSession
            //self.readerSession = nil
            // session?.invalidate()
            Log.debug( "error- \(error)" )
            switch(error)
            {
                case 0:  // OK
                    session?.alertMessage = "Lettura avvenuta con successo.\nPuoi rimuovere la carta mentre completiamo la verifica dei dati."
                    let response = String(data: data!, encoding: .utf8)
                    let codiceServer = String((response?.split(separator: ":")[1])!)
                    let newurl = nextUrl + "?" + name + "=" + value + "&login=1&codice=" + codiceServer
                    self.completedHandler(nil, newurl)
                    session?.invalidate()
                    break;
                case 0x63C0,0x6983: // PIN LOCKED
                    self.attemptsLeft = 0
                    session?.invalidate(errorMessage: "Carta CIE bloccata")
                    self.completedHandler("ON_CARD_PIN_LOCKED", nil)
                    break;
                
                case 0x63C1: // WRONG PIN 1 ATTEMPT LEFT
                    self.attemptsLeft = 1
                    self.completedHandler("ON_PIN_ERROR", nil)
                    session?.invalidate(errorMessage: "PIN errato, hai ancora 1 tentativo")
                    break;
                
                case 0x63C2: // WRONG PIN 2 ATTEMPTS LEFT
                    self.attemptsLeft = 2
                    self.completedHandler("ON_PIN_ERROR", nil)
                    session?.invalidate(errorMessage: "PIN errato, hai ancora 2 tentativi")
                    break;
                
                default: // OTHER ERROR
                    self.completedHandler(ErrorHelper.decodeError(error: error), nil)
                    session?.invalidate(errorMessage:ErrorHelper.nativeError(errorMessage:ErrorHelper.decodeError(error: error)))
                    break;
                
            }            
        })
    }
}

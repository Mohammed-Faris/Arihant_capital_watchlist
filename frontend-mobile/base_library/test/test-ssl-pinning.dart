import 'dart:io';
import 'package:asn1lib/asn1lib.dart';
import 'package:convert/convert.dart';

// Reference - http://www.lapo.it/asn1js/
// Test & Check tools.
//  openssl s_client -connect dev.gwcindia.in:443 2>/dev/null </dev/null |  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > gwc.crt
//  openssl x509 -pubkey -noout -in gwc.crt > gwc_pub.pem
//  ruby asn.rb gwc_pub.pem

// GWC -- Server -- Will be received from Infra
// This is the representation of Public key in Hexadecimal. The public key of Owner's or
List<String> sslHexASN1PubKeys = [
  '3082010a0282010100e209a3af1e6e7bfd03c26d370bdd0478ced084ad9b6dcb78d94f697b926e3237da082e7a14ec589b73764b7beaa3acc2e1cadd09a9004c295c4fae67f6d593a382ab4c8bdc773d1264c893f740729d01ecbf83306a72cb9f0d4d7e06618c39c90901749dcdc707da7bf8486f442f815ffbc6571d32037c1f89bd91a37d6e1088b6170c1f294c0b68a7eadfd8e3377b476a9d5d3aa198c33aeab4a6ef01209bf18d6f499d5214a10f337bdfd7b6105246857f4c9d95bba231ace83124009b542e2efca4dab54a61f7f5e9e54c4fc01115ee170de0b9749fa50d7fbef87306cc2f2d2a32b53c2238cfd13f98c16b26e7dd7f835ce25660813b47db26324ceeb7c10203010001'
];

List<int> getSSLPubKey(X509Certificate x509certificate) {
  ASN1Parser p = ASN1Parser(x509certificate.der);
  ASN1Sequence signedCert = p.nextObject() as ASN1Sequence;
  ASN1Sequence cert = signedCert.elements[0] as ASN1Sequence;
  ASN1Sequence pubKeyElement = cert.elements[6] as ASN1Sequence;
  ASN1BitString pubKeyBits = pubKeyElement.elements[1] as ASN1BitString;

  return pubKeyBits.stringValue;
}

bool doSSLPubKeyPinning(X509Certificate cert) {
  List<int> sslPubKey = getSSLPubKey(cert);

  String hexASN1 = hex.encode(sslPubKey);

  return sslHexASN1PubKeys.contains(hexASN1);
}

void callHTTP() async {
  final HttpClient client = HttpClient();

  String u = "https://dev.gwcindia.in/virtual-trade/Config/Base/1.0.0";

  final HttpClientRequest request = await client.postUrl(Uri.parse(u));

  final HttpClientResponse response = await request.close();

  if (response.certificate != null && doSSLPubKeyPinning(response.certificate!))
    print("SSL pinning success\n");
  else
    print("Fail... SSL pinning\n");
}

void main() {
  print('SSL ');

  callHTTP();
}

//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

print("{\"udacity\": {\"username\": \"account@domain.com\", \"password\": \"********\"}}")

let url = "https://parse.udacity.com/parse/classes/StudentLocation?where={\"uniqueKey\":\"1234\"}"
let escapedURL:String! = url.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)

print(escapedURL)
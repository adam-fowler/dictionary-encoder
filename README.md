# Dictionary Encoder
<div>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-5.0-brightgreen.svg" alt="Swift 5.0" />
    </a>
    <a href="https://travis-ci.org/adam-fowler/dictionary-encoder">
        <img src="https://travis-ci.org/adam-fowler/dictionary-encoder.svg?branch=master" alt="Travis Build" />
    </a>
</div>

Swift Dictionary Encoder and Decoder, based off the JSONEncoder in Foundation.

Internally the JSONEncoder in the Swift Foundation creates a dictionary before encoding to JSON and the JSONDecoder works from a Dictionary parsed from JSON data. This encoding/decoding to and from a dictionary is hidden and not available to the user. 

DictionaryEncoder is essentially the same as JSONEncoder but instead of returning JSON data, it returns the ```Dictionary<String, Any>``` the JSON data would have been generated from. Likewise DictionaryDecoder is essentially the same as JSONDecoder except it's input is a ```Dictionary<String, Any>```.

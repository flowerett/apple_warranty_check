require "apple_warranty_check/version"
require 'net/http'

module AppleWarrantyCheck
  class Process
    CHECK_URL = 'https://selfsolve.apple.com/wcResults.do'.freeze

    PRODUCT_INFO_REGEXP = /warrantyPage.warrantycheck.displayProductInfo\((.*)\);/
    PH_SUPPORT_INFO_REGEXP = /warrantyPage.warrantycheck.displayPHSupportInfo\((.*)\);/
    HW_SUPPORT_INFO_REGEXP = /warrantyPage.warrantycheck.displayHWSupportInfo\((.*)\);/

    ERR_RESP_REGEXP = /var errorMsg = '(.*)';/

    attr_accessor :imei

    def initialize(imei=nil)
      @imei = imei
    end

    def run
      parse_body get_response.body
    end

    def parse_body(html)
      if ERR_RESP_REGEXP.match(html).nil?
        [
          [:prodImgUrl, :prodDesc, :isIMEINum, :APIMEINum, :isProdId, :prodId, :sn],
          PRODUCT_INFO_REGEXP.match(html)[1].split(',').map(&:strip)
        ].transpose.to_h
      else
        { error: ERR_RESP_REGEXP.match(html)[1] }
      end
    end

    def get_response
      uri = URI(CHECK_URL)
      params = {sn: imei, Continue: 'Continue', cn: '', local: '', caller: '', num: 0 }

      uri.query = URI.encode_www_form(params)

      Net::HTTP.get_response(uri)
    end
  end
end

require "apple_warranty_check/version"
require 'net/http'

module AppleWarrantyCheck
  class Process
    CHECK_URL = 'https://selfsolve.apple.com/wcResults.do'.freeze

    STR_ARG = "'(.*)'".freeze
    BOOL_ARG = "(true|false)".freeze

    PRODUCT_INFO_REGEXP = /warrantyPage.warrantycheck.displayProductInfo\((.*)\)/.freeze
    PH_SUPPORT_INFO_REGEXP = /warrantyPage.warrantycheck.displayPHSupportInfo\(\s*#{BOOL_ARG},\s*#{STR_ARG},\s*#{STR_ARG},\s*#{STR_ARG}/
    HW_SUPPORT_INFO_REGEXP = /warrantyPage.warrantycheck.displayHWSupportInfo\(\s*#{BOOL_ARG},\s*#{STR_ARG},\s*#{STR_ARG},\s*#{STR_ARG},\s*#{STR_ARG}/.freeze

    PH_SUPPORT_STATUS = /Telephone Technical Support: (Active|Expired)/.freeze
    HW_SUPPORT_STATUS = /Repairs and Service Coverage: (Active|Expired)/.freeze
    EXP_DATE = /Estimated Expiration Date: (.*\s\d{2},\s\d{4})/.freeze

    ERR_RESP_REGEXP = /var errorMsg = '(.*)';/

    PRODUCT_INFO_KEYS = %i(prodImgUrl prodDesc isIMEINum APIMEINum isProdId prodId sn).freeze
    PH_SUPPORT_INFO_KEYS = %i(hasPhoneSuppCov phoneSuppSubHeader phoneSuppCovTxt phoneSuppLink).freeze
    HW_SUPPORT_INFO_KEYS = %i(hasHWSuppCov HWRepairSubHead HWSuppCovTxt HWSuppLnk hasCLMessageCode).freeze

    attr_accessor :imei

    def initialize(imei=nil)
      @imei = imei
    end

    def run
      parse_body get_response.body
    end

    def parse_body(html)
      if ERR_RESP_REGEXP.match(html).nil?
        {
          product_info: get_product_info(html),
          phone_support: get_phone_support_info(html),
          hw_support: get_hw_support_info(html)
        }
      else
        { error: ERR_RESP_REGEXP.match(html)[1] }
      end
    end

    def get_phone_support_info(html)
      get_support_info PH_SUPPORT_INFO_REGEXP, PH_SUPPORT_INFO_KEYS, PH_SUPPORT_STATUS, html
    end

    def get_hw_support_info(html)
      get_support_info HW_SUPPORT_INFO_REGEXP, HW_SUPPORT_INFO_KEYS, HW_SUPPORT_STATUS, html
    end

    def get_product_info(html)
      [
        PRODUCT_INFO_KEYS,
        PRODUCT_INFO_REGEXP.match(html)[1].split(',').map{ |el| el.strip.gsub('\'', '') }
      ].transpose.to_h
    end

    private

    def get_response
      uri = URI(CHECK_URL)
      params = {sn: imei, Continue: 'Continue', cn: '', local: '', caller: '', num: 0 }

      uri.query = URI.encode_www_form(params)

      Net::HTTP.get_response(uri)
    end

    def get_support_info(regexp, keys, status_regexp, html)
      match_data = regexp.match(html)

      keys.map.with_index{ |el, i| [el, match_data[i+1]] }.to_h.
        merge!(
          support_status: status_regexp.match(match_data[2])[1],
          expiration_date: (EXP_DATE.match(match_data[3])[1] rescue nil)
        )
    end
  end
end

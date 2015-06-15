require 'net/http'

module AppleWarrantyCheck
  class Process
    CHECK_URL = 'https://selfsolve.apple.com/wcResults.do'.freeze

    STR_ARG = "'(.*)'".freeze
    BOOL_ARG = "(true|false)".freeze

    PRODUCT_INFO_REGEXP = /warrantyPage.warrantycheck.displayProductInfo\((.*)\)/.freeze
    PH_SUPPORT_INFO_REGEXP = /warrantyPage.warrantycheck.displayPHSupportInfo\(\s*#{BOOL_ARG},\s*#{STR_ARG},\s*#{STR_ARG},\s*#{STR_ARG}/.freeze
    HW_SUPPORT_INFO_REGEXP = /warrantyPage.warrantycheck.displayHWSupportInfo\(\s*#{BOOL_ARG},\s*#{STR_ARG},\s*#{STR_ARG},\s*#{STR_ARG},\s*#{STR_ARG}/.freeze

    PH_SUPPORT_STATUS = /Telephone Technical Support: (Active|Expired)/.freeze
    HW_SUPPORT_STATUS = /Repairs and Service Coverage: (Active|Expired)/.freeze
    EXP_DATE = /Estimated Expiration Date: (.*\s\d{2},\s\d{4})/.freeze

    ERR_RESP_REGEXP = /var errorMsg = '(.*)';/.freeze

    NOT_REGISTERED_REGEXP = /window.location.href =(.*);/.freeze

    PRODUCT_INFO_KEYS = %i(prodImgUrl prodDesc isIMEINum APIMEINum isProdId prodId sn).freeze
    PH_SUPPORT_INFO_KEYS = %i(hasPhoneSuppCov phoneSuppSubHeader phoneSuppCovTxt phoneSuppLink).freeze
    HW_SUPPORT_INFO_KEYS = %i(hasHWSuppCov HWRepairSubHead HWSuppCovTxt HWSuppLnk hasCLMessageCode).freeze

    attr_accessor :imei, :response

    def initialize(imei=nil)
      @imei = imei
    end

    def run
      @response = get_response

      case response
      when Net::HTTPSuccess
        parse_body response.body
      else
        error_msg [response.code, response.message].join(': ')
      end
    end

    def parse_body(html)
      return error_response(html) unless ERR_RESP_REGEXP.match(html).nil?

      return not_registered unless NOT_REGISTERED_REGEXP.match(html).nil?

      {
        product_info: get_product_info(html),
        phone_support: get_phone_support_info(html),
        hw_support: get_hw_support_info(html)
      }
    end

    def get_phone_support_info(html)
      get_support_info PH_SUPPORT_INFO_REGEXP, PH_SUPPORT_INFO_KEYS, PH_SUPPORT_STATUS, html
    end

    def get_hw_support_info(html)
      get_support_info HW_SUPPORT_INFO_REGEXP, HW_SUPPORT_INFO_KEYS, HW_SUPPORT_STATUS, html
    end

    def get_product_info(html)
      process_with_exception 'could not find product info' do
        [
          PRODUCT_INFO_KEYS,
          PRODUCT_INFO_REGEXP.match(html)[1].split(',').map{ |el| el.strip.gsub('\'', '') }
        ].transpose.to_h
      end
    end

    private

    def get_response
      uri = URI(CHECK_URL)
      params = {sn: imei, Continue: 'Continue', cn: '', local: '', caller: '', num: 0 }

      uri.query = URI.encode_www_form(params)

      res = Net::HTTP.get_response(uri)
    end

    def get_support_info(regexp, keys, status_regexp, html)
      process_with_exception 'could not find support info' do
        match_data = regexp.match(html)

        keys.map.
          with_index{ |el, i| [el, match_data[i+1]] }.
          to_h.
          merge!(
            support_status: status_regexp.match(match_data[2])[1],
            expiration_date: (EXP_DATE.match(match_data[3])[1] rescue nil)
          )
      end
    end

    def process_with_exception(message)
      yield
    rescue NoMethodError
      message
    end

    def error_response(html)
      error_msg ERR_RESP_REGEXP.match(html)[1]
    end

    # TODO follow redirect to get live apple message
    def not_registered
      error_msg "Please validate your product's purchase date. Apple is unable to provide information about your service coverage."
    end

    def error_msg(message)
      { error: message }
    end
  end
end

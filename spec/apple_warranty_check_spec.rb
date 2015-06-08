require 'spec_helper'

describe AppleWarrantyCheck do
  it 'has a version number' do
    expect(AppleWarrantyCheck::VERSION).to eq '0.0.1'
  end

  describe '#parse_body' do
    it 'returns device data from valid html response' do
      valid_warranty_html =  File.open('spec/files/valid_warranty_resp.html').read

      product_info = AppleWarrantyCheck::Process.new().parse_body valid_warranty_html

      expect(product_info).to be_a Hash
      expect(product_info[:APIMEINum]).to eq "'013977000323877'"
      expect(product_info[:prodDesc]).to eq "'iPhone 5c'"
    end

    it 'returns device data from expired html response' do
      expired_warranty_html =  File.open('spec/files/expired_warranty_resp.html').read

      product_info = AppleWarrantyCheck::Process.new().parse_body expired_warranty_html

      expect(product_info).to be_a Hash
      expect(product_info[:APIMEINum]).to eq "'013896000639712'"
      expect(product_info[:prodDesc]).to eq "'iPhone 5c'"
    end

    it 'returns error message from invalid html response' do
      invalid_imei_html =  File.open('spec/files/invalid_sn_resp.html').read

      product_info = AppleWarrantyCheck::Process.new().parse_body invalid_imei_html

      expect(product_info[:error]).to match(/serial number you have provided cannot be found/)
    end
  end
end

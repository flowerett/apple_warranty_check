require 'spec_helper'

describe AppleWarrantyCheck do
  it 'has a version number' do
    expect(AppleWarrantyCheck::VERSION).to eq '0.0.5'
  end

  let(:valid_warranty_html)  { File.open('spec/files/valid_warranty_resp.html').read }
  let(:expired_warranty_html)  { File.open('spec/files/expired_warranty_resp.html').read }
  let(:invalid_imei_html)  { File.open('spec/files/invalid_sn_resp.html').read }

  let(:pr) { AppleWarrantyCheck::Process.new() }

  describe '#run' do
    it 'returns active result from apple site' do
      info = AppleWarrantyCheck::Process.new('013977000323877').run

      expect(info[:product_info][:APIMEINum]).to eq "013977000323877"
      expect(info[:hw_support][:support_status]).to eq 'Active'
      expect(info[:hw_support][:expiration_date]).to eq "August 10, 2016"
    end

    it 'returns expired result from apple site' do
      info = AppleWarrantyCheck::Process.new('013896000639712').run

      expect(info[:product_info][:APIMEINum]).to eq "013896000639712"
      expect(info[:hw_support][:support_status]).to eq 'Expired'
      expect(info[:hw_support][:expiration_date]).to be_nil
    end
  end

  describe '#parse_body' do
    it 'returns error message from invalid html response' do
      info = pr.parse_body invalid_imei_html

      expect(info[:error]).to match(/serial number you have provided cannot be found/)
    end

    it 'returns info hash for valid html response' do
      info = pr.parse_body valid_warranty_html

      expect(info.keys).to eq %i(product_info phone_support hw_support)
      expect(info[:product_info][:APIMEINum]).to eq "013977000323877"
      expect(info[:hw_support][:support_status]).to eq 'Active'
      expect(info[:hw_support][:expiration_date]).to eq "August 10, 2016"
    end

    it 'returns info hash for expired html response' do
      info = pr.parse_body expired_warranty_html

      expect(info.keys).to eq %i(product_info phone_support hw_support)
      expect(info[:product_info][:APIMEINum]).to eq "013896000639712"
      expect(info[:hw_support][:support_status]).to eq 'Expired'
      expect(info[:hw_support][:expiration_date]).to be_nil
    end
  end

  describe '#get_product_info' do
    it 'returns device data from valid html response' do
      info = pr.get_product_info valid_warranty_html

      expect(info).to be_a Hash
      expect(info[:APIMEINum]).to eq "013977000323877"
      expect(info[:prodDesc]).to eq "iPhone 5c"
    end

    it 'returns device data from expired html response' do
      info = pr.get_product_info expired_warranty_html

      expect(info).to be_a Hash
      expect(info[:APIMEINum]).to eq "013896000639712"
      expect(info[:prodDesc]).to eq "iPhone 5c"
    end
  end

  describe '#get_phone_support_info' do
    it 'returns phone support data from valid html response' do
      info = pr.get_phone_support_info valid_warranty_html

      expect(info).to be_a Hash
      expect(info[:hasPhoneSuppCov]).to eq 'true'
      expect(info[:support_status]).to eq "Active"
      expect(info[:expiration_date]).to eq "August 10, 2016"
    end

    it 'returns phone support data from expired html response' do
      info = pr.get_phone_support_info expired_warranty_html

      expect(info).to be_a Hash
      expect(info[:hasPhoneSuppCov]).to eq 'false'
      expect(info[:support_status]).to eq "Expired"
      expect(info[:expiration_date]).to be_nil
    end
  end

  describe '#get_hw_support_info' do
    it 'returns hardware support data from valid html response' do
      info = pr.get_hw_support_info valid_warranty_html

      expect(info).to be_a Hash
      expect(info[:hasHWSuppCov]).to eq 'true'
      expect(info[:support_status]).to eq "Active"
      expect(info[:expiration_date]).to eq "August 10, 2016"
    end

    it 'returns hardware support data from expired html response' do
      info = pr.get_hw_support_info expired_warranty_html

      expect(info).to be_a Hash
      expect(info[:hasHWSuppCov]).to eq 'false'
      expect(info[:support_status]).to eq "Expired"
      expect(info[:expiration_date]).to be_nil
    end
  end
end

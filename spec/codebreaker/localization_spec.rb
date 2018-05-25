require 'spec_helper'

module Codebreaker
  RSpec.describe Localization do

    let(:localization)       { Localization.new(:game) }
    let(:localization_wrong) { Localization.new(:console, :eg) }

    describe '#new' do
      describe '#initialize' do
        describe 'without args' do
          specify { expect { subject }.to raise_error(ArgumentError) }
        end

        describe 'with args' do
          describe '1 argument' do
            context 'when wrong app type' do
              let(:local_wrong_app) { Localization.new(:wrong_type) }
              specify { expect { local_wrong_app }.to raise_error(RuntimeError, 'Unknown application type.') }
            end
            
            context 'when right app type' do
              specify { expect(localization).to be_an_instance_of(Localization) }
            end
          end

          describe '2 arguments' do
            context 'when wrong app type' do
              let(:local_wrong_app) { Localization.new(:wrong_type, :ru) }
              specify { expect { local_wrong_app }.to raise_error(RuntimeError, 'Unknown application type.') }
            end

            context 'when wrong lang' do
              specify { expect(localization_wrong).to be_an_instance_of(Localization) }
            end
          end
        end
      end

      describe '#select_application' do
        context 'should create instance var with app type' do
          specify { expect(localization.instance_variable_get(:@app_dir)).to eq('game') }
        end
      end

      describe '#candidates_to_load' do
        context 'should create instance var with file list' do
          specify { expect(localization.instance_variable_get(:@ymls_paths)).to be_an_instance_of(Array) }
        end
      end

      describe '#merge_localizations' do
        context 'should create instance var with localizations' do
          specify { expect(localization.instance_variable_get(:@localizations)).to be_an_instance_of(Hash) }
        end
      end
    end

    describe '#localization' do
      context 'return default localization if no localization found' do
        specify { expect(localization_wrong.localization.first).eq have_key(:en) }
      end
    end
  end
end
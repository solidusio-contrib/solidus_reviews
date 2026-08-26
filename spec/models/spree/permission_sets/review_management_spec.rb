# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"
require "spree/testing_support/dummy_ability"

RSpec.describe Spree::PermissionSets::ReviewManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  it { expect(described_class.privilege).to eq(:management) }
  it { expect(described_class.category).to eq(:product) }

  context "when activated" do
    before { described_class.new(ability).activate! }

    it { is_expected.to be_able_to(:display, Spree::Review) }
    it { is_expected.to be_able_to(:admin, Spree::Review) }
    it { is_expected.to be_able_to(:update, Spree::Review) }
    it { is_expected.to be_able_to(:destroy, Spree::Review) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, Spree::Review) }
  end
end

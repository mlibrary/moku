# frozen_string_literal: true

require "moku/policy"

module Moku
  RSpec.describe Policy do
    RSpec.shared_examples "can perform" do |name, roles, action|
      it "#{name} can peform #{action}" do
        expect(described_class.new(roles).authorized?(action)).to be true
      end
    end

    RSpec.shared_examples "cannot perform" do |name, roles, action|
      it "#{name} cannot peform #{action}" do
        expect(described_class.new(roles).authorized?(action)).to be false
      end
    end

    describe "deploy actions" do
      [
        :deploy, :rollback, :exec
      ].each do |action|
        include_examples "can perform", "admins", [:admin], action
        include_examples "can perform", "deployers", [:deploy], action
        include_examples "cannot perform", "editors", [:edit], action
        include_examples "cannot perform", "readers", [:read], action
        include_examples "cannot perform", "restarter", [:restart], action
        include_examples "cannot perform", "nobodies", [], action
      end
    end

    describe "restart actions" do
      [
        :restart
      ].each do |action|
        include_examples "can perform", "admins", [:admin], action
        include_examples "can perform", "deployers", [:deploy], action
        include_examples "cannot perform", "editors", [:edit], action
        include_examples "cannot perform", "readers", [:read], action
        include_examples "can perform", "restarter", [:restart], action
        include_examples "cannot perform", "nobodies", [], action
      end
    end

    describe "read actions" do
      [
        :read_default_branch, :caches, :releases
      ].each do |action|
        include_examples "can perform", "admins", [:admin], action
        include_examples "can perform", "deployers", [:deploy], action
        include_examples "can perform", "editors", [:edit], action
        include_examples "can perform", "readers", [:read], action
        include_examples "cannot perform", "restarter", [:restart], action
        include_examples "cannot perform", "nobodies", [], action
      end
    end

    describe "edit actions" do
      [
        :set_default_branch
      ].each do |action|
        include_examples "can perform", "admins", [:admin], action
        include_examples "cannot perform", "deployers", [:deploy], action
        include_examples "can perform", "editors", [:edit], action
        include_examples "cannot perform", "readers", [:read], action
        include_examples "cannot perform", "restarter", [:restart], action
        include_examples "cannot perform", "nobodies", [], action
      end
    end
  end
end

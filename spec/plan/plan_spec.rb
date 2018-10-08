require "fauxpaas/plan/plan"

module Fauxpaas
  RSpec.describe Plan::Plan do

    RSpec.shared_examples "a plan" do
      let(:target) { double(:target) }
      [:prepare, :main, :finish].each do |method|
        it "#{method} returns an array" do
          expect(described_class.new(target).send(method)).to be_an Array
        end
      end
    end

    it_behaves_like "a plan"

    class TestPlan < described_class
      def initialize(target:, prepare: [], main: [], finish: [])
        super(target)
        @prepare = prepare
        @main = main
        @finish = finish
        @main_determined = false
        @finish_determined = false
      end

      attr_reader :main_determined, :finish_determined

      def prepare
        @prepare
      end
      def main
        @main_determined = true
        @main
      end
      def finish
        @finish_determined = true
        @finish
      end
    end

    describe "#call" do
      let(:target) { double(:target) }
      let(:failure) { double(:success, success?: false, error: "error") }
      let(:success) { double(:success, success?: true, error: nil) }

      it "determines main,finish tasks after completing prepare tasks" do
        plan = TestPlan.new(
          target: target,
          prepare: [ ->(_){ failure } ]
        )
        plan.call
        expect(plan.main_determined).to be false
        expect(plan.finish_determined).to be false
      end

      it "determines finish tasks after completing main tasks" do
        plan = TestPlan.new(
          target: target,
          main: [ ->(_){ failure } ]
        )
        plan.call
        expect(plan.finish_determined).to be false
      end

      describe "returns" do
        context "(when successful)" do
          let(:plan) { described_class.new(target) }
          it { expect(plan.call.success?).to be true }
        end
        context "(when unsuccessful)" do
          let(:plan) do
            TestPlan.new(
              target: target,
              main: [
                ->(_){ success },
                ->(_){ failure }
              ]
            )
          end
          it { expect(plan.call.success?).to be false }
        end
      end

      it "passes the target to each step" do
        plan = TestPlan.new(
          target: target,
          main: [
            ->(t){
              expect(t).to eql(target)
              success
            }
          ]
        )
        plan.call
      end

    end

  end
end

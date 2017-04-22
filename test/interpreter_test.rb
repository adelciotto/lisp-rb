require_relative 'test_helper.rb'
require_src 'interpreter.rb'

describe Interpreter do
  let(:interpreter) { Interpreter.new }

  describe '#eval' do
    let(:expression) { 'nil' }

    describe 'when expression is nil' do
      it 'should return nil' do
        assert_nil interpreter.eval(expression)
      end
    end

    describe 'binary operators' do
      let(:operator) { '+' }
      let(:args) { [1, 2, 3] }
      let(:expression) { "(#{operator} #{args.join(' ')})" }
      let(:result) { 6 }

      describe 'addition' do
        describe 'when there are arguments' do
          it 'should add all the arguments' do
            assert_equal interpreter.eval(expression), result
          end
        end

        describe 'when there are no arguments' do
          let(:args) { [] }
          let(:result) { 0 }

          it 'should return 0' do
            assert_equal interpreter.eval(expression), result
          end
        end
      end

      describe 'subtraction' do
        let(:operator) { '-' }
        let(:result) { -4 }

        describe 'when there are arguments' do
          it 'should subtract all the arguments' do
            assert_equal interpreter.eval(expression), result
          end
        end

        describe 'when there are no arguments' do
          let(:args) { [] }

          it 'should raise a LispError' do

          end
        end

        describe 'when there is one argument' do
          let(:result) { 4 }
          let(:args) { [result] }

          it 'returns the argument' do
            assert_equal interpreter.eval(expression), result
          end
        end
      end

      describe 'muliplication' do
        let(:operator) { '*' }
        let(:result) { 6 }

        it 'should multiply all the arguments' do
          assert_equal interpreter.eval(expression), result
        end
      end

      describe 'division' do
        let(:operator) { '/' }
        let(:args) { [9, 3] }
        let(:result) { 3 }

        it 'should divide all the arguments' do
          assert_equal interpreter.eval(expression), result
        end
      end

      #describe 'equal to' do
        #let(:operator) { '==' }
        #let(:)
      #end
    end
  end
end

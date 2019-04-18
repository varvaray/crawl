module Entities
  class Error < Grape::Entity
    expose :error, documentation: { type: 'String', desc: 'Error message', required: true, example: 'Error' }
    expose :details, expose_nil: false, documentation: { type: 'String', desc: 'Error description', example: 'Error explanation' }
  end
end
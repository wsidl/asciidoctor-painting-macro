RUBY_ENGINE == 'opal' ? (require 'painting-macro/extension') : (require_relative 'painting-macro/extension')

Extensions.register do
  block_macro PaintingBlockMacroProcessor
  treeprocessor PaintingTOCTreeprocessor
end

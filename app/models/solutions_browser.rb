class SolutionsBrowser

  attr_reader :columns, :labels, :relations, :solutions

  def initialize(solutions=[])
    @solutions = solutions
  end

  def columns
    @solutions.variable_names
  end

  def relations
    columns.select { |c| c.to_s.match(/_id$/) }
  end

  def labels
    columns.reject { |c| c.to_s.match(/_id$/) }
  end

  def label_has_id?(label)
    relations.include?(relationize(label))
  end

  def relation_value_for_label(solution, label)
    return unless label_has_id? (label)

    value(solution, relationize(label)).to_s.split("#")[1]
  end

  def value(solution, label)
    solution[label]
  end

  private

  def relationize label
    "#{label}_id".to_sym
  end

end

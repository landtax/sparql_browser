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

    value(solution, relationize(label)).split("#")[1]
  end

  def value(solution, label)
    solution[label].to_s
  end

  def facet_label_column
    labels.first
  end

  def facet_has_id?
    label_has_id?(facet_label_column)
  end

  def facet_name(solution)
     solution[facet_label_column].to_s
  end

  def facet_id(solution)
     relation_value_for_label(solution, facet_label_column).to_s
  end

  def facets
    myfacets = {}

    @solutions.each do |s|
      key = facet_name(s)
      if myfacets[key].nil?
        myfacets[key] = {:label => key, :id => facet_id(s), :solutions => []}
      else
        myfacets[key][:solutions] << s
      end
    end

   myfacets 
  end

  private

  def relationize label
    "#{label}_id".to_sym
  end

end

require Rails.root.join('app', 'controllers', 'concerns', 'manipulate_node')

module ManipulateNodeFix

    def node_check(el)
        newnode = el.clone
        if newnode.key? "render"
            newnode = process_render(newnode)
        elsif newnode.name.match(/ptr$/)
            newnode = process_pointer(newnode)
        elsif  newnode.name.match(/^extref/)
            newnode = process_anchor(newnode)
        elsif  newnode.name.match(/^ref$/)
            newnode = process_ref(newnode)
        elsif newnode.name == 'blockquote'
            newnode.name = 'blockquote'
        elsif newnode.name == 'table'
            newnode.name = 'table'
            newnode['class'] = "table"
        elsif newnode.name == 'head'
            newnode.name = 'caption'
        elsif newnode.name == 'thead'
            newnode.name = 'thead'
        elsif newnode.name == 'tbody'
            newnode.name = 'tbody'
        elsif newnode.name == 'row'
            newnode.name = 'tr'
        elsif newnode.name == 'entry'
            if el.ancestors('thead').length > 0
                newnode.name = 'th'
            else
                newnode.name = 'td'
            end
        elsif newnode.name == 'lb'
            newnode.name = 'br'
        else
            if !newnode.name.match(/^(p|ul|li|br|h5)$/)
                if newnode.name == 'date'
                    newnode.remove_attribute('calendar')
                    newnode.remove_attribute('era')
                end
                clss = newnode['class'] || ''
                role = newnode['role'] ||''
                unless role.blank?
                    newnode.remove_attribute('role')
                end
                newnode['class']  = "#{newnode.name} #{clss} #{role}".strip
                newnode.name = newnode.name == 'accession' ? 'div' : 'span'
            end
        end

        if !newnode.name.match(/^ref$/)
            newnode = process_anchor(newnode) if newnode.name != 'a'
        end
        el.replace(newnode)
    end

    def process_ref(node)
        href = node['href']
        href.strip! if href
        
        target = node['target']
        target.strip! if target
        
        return node if href.blank? && target.blank?
        
        title = node['title']
        title.strip! if title

        content = node.content || title || 'reference'
        content.strip! if content

        anchornode = node.document.create_element('a')
        anchornode['href'] = href || "\##{target}"
        anchornode['title'] = title if title
        anchornode['target'] = '_blank'
        anchornode.add_child(content)

        anchornode
    end

end

ManipulateNode.prepend ManipulateNodeFix
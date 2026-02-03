module helper.xml;

import std.file;
import std.path;
import std.array;
import std.string;
import std.conv;
import core.sync.mutex;

import dxml.parser;
import dxml.dom;

import helper.app_path;

alias Node = DOMEntity!string;

/// Simple XML helper class using dxml
class Xml
{
    private Node dom;
    private string xmlText;
    private string fullPath;
    private Mutex writeMutex;

    /// Default constructor loads the default config
    this()
    {
        fullPath = app_path.getFullyQualifiedDirPath(defaultDir());
        if (!exists(fullPath))
            mkdirRecurse(fullPath);
        loadDefault();
    }

    /// Load XML from a specific path
    this(string path)
    {
        fullPath = path;
        if (!exists(fullPath))
            write(path, "");
        loadFromFile(path);
    }

    /// Directory to store XML configs
    string defaultDir() const
    {
        return "confs";
    }

    /// Default config path
    string getDefaultConf()
    {
        return buildPath(app_path.getFullyQualifiedDirPath(defaultDir()),
                         app_path.getProjectName() ~ ".xml");
    }

    /// Get config path by name
    string getConf(string name)
    {
        return buildPath(app_path.getFullyQualifiedDirPath(defaultDir()),
                         name ~ ".xml");
    }

    /// Load default XML
    void loadDefault()
    {
        synchronized(writeMutex)
        {
            loadXml(getDefaultConf());
        }
    }

    /// Load XML from file
    void loadFromFile(string path)
    {
        synchronized(writeMutex)
        {
            loadXml(path);
        }
    }

    /// Load a separate XML file and return a DOM
    Node loadSeparate(string path)
    {
        return parseDOM(readText(path));
    }

    /// Write XML back to file
    void write()
    {
        synchronized(writeMutex)
        {
            write(getDefaultConf(), xmlText);
        }
    }

    /// Write XML to a specific path
    void write(string path)
    {
        synchronized(writeMutex)
        {
            write(path, xmlText);
        }
    }

    /// Access the root DOM node
    Node document() { return dom; }

    /// Find all nodes with a given tag recursively
    Node[] allByTag(string tag)
    {
        Node[] asdf;
        foreach (c; dom.children)
            walk(c, asdf, tag);
        return asdf;
    }

    /// Find node by path like ["root", "child", "subchild"]
    Node nodeByPath(string[] path)
    {
        if (dom.children.length == 0)
            return Node.init;

        Node cur = dom.children[0];

        foreach (p; path)
        {
            bool found = false;
            foreach (c; cur.children)
            {
                if (c.type == EntityType.elementStart && c.name == p)
                {
                    cur = c;
                    found = true;
                    break;
                }
            }
            if (!found)
                return Node.init;
        }

        return cur;
    }

    /// Get children with specific tag
    Node[] childrenByTag(Node parent, string tag)
    {
        Node[] asdf;
        foreach (c; parent.children)
            if (c.type == EntityType.elementStart && c.name == tag)
                asdf ~= c;
        return asdf;
    }

    /// Find node by attribute
    Node findNodeByAttribute(string tag, string attr, string value = "")
    {
        Node found;
        foreach (c; dom.children)
        {
            walkAttr(c, found, tag, attr, value);
            if (found.type != EntityType.invalid)
                break;
        }
        return found;
    }

    /// Get a map of node attributes
    string[string] getNodeAttributes(Node node)
    {
        string[string] asdf;
        foreach (a; node.attributes)
            asdf[a.name] = a.value;
        return asdf;
    }

    /// Get attribute value or default
    string getAttr(Node node, string name, string def = "")
    {
        foreach (a; node.attributes)
            if (a.name == name)
                return a.value;
        return def;
    }

    /// Concatenate text of all child text nodes
    string innerText(Node node)
    {
        string asdf;
        foreach (c; node.children)
            if (c.type == EntityType.text)
                asdf ~= c.text;
        return asdf;
    }

    /// ----------------- private -----------------
    private void loadXml(string path)
    {
        if (!exists(path))
        {
            dom = Node.init;
            xmlText = "";
            return;
        }

        xmlText = readText(path);
        dom = parseDOM(xmlText);
    }

    /// Recursive search for tag
    private void walk(Node n, ref Node[] asdf, string tag)
    {
        if (n.type == EntityType.elementStart && n.name == tag)
            asdf ~= n;

        foreach (c; n.children)
            walk(c, asdf, tag);
    }

    /// Recursive search for attribute
    private void walkAttr(Node n, ref Node found, string tag, string attr, string value)
    {
        if (found.type != EntityType.invalid)
            return;

        if (n.type == EntityType.elementStart && n.name == tag)
        {
            foreach (a; n.attributes)
            {
                if (a.name == attr && (value.length == 0 || a.value == value))
                {
                    found = n;
                    return;
                }
            }
        }

        foreach (c; n.children)
            walkAttr(c, found, tag, attr, value);
    }
}

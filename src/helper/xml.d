module helper.xml;

// todo; move these into functions when built up
static import dxml.dom;
static import dxml.parser;
static import dxml.util;
static import dxml.writer;
static import std.file;
static import helper.app_path;
static import std.path;
static import std.array;

// for GC reasons you should struct this at some point
struct Xml {
public:
    this(string fullyQualifiedFilePathPath) {
        setFullPath(fullyQualifiedFilePathPath);
        if (!std.file.exists(fullPath())) {
            helper.app_path.createFile(fullPath());
        }
        setStAXParser(false);
        setXml();
    }



    void
    setFullyQualifiedXmlFilePath(string fullyQualifiedXmlFilePath) {
        this.fullyQualifiedXmlFilePath_ = fullyQualifiedXmlFilePath;
    }

    string
    fullyQualifiedXmlFilePath() {
        return this.fullyQualifiedXmlFilePath_;
    }

    void
    setFullPath(string fullPath) {
        this.fullPath_ = fullPath;
    }

    string
    fullPath() {
        return this.fullPath_;
    }

    dxml.dom.DOMEntity!(string)
    xmlDom() {
        return this.xmlDom_;
    }

    dxml.parser.Config
    xmlConfig() {
        // todo; revise this to have a setter maybe if i ever want it.
        return this.xmlConfig_;
    }

    static string
    fullDefaultXmlFile() {
        std.array.Appender!string buf;
        buf.put(std.path.buildPath(helper.app_path.getProjectPath(), "confs"));
        buf.put(helper.app_path.getProjectName());
        return buf.opSlice;
    }

private:
    enum string fileType = ".xml";
    // Effectively the same thing as 
    // > dxml.parser.simpleXml
    // but I want to be explicit
    enum dxml.parser.Config xmlConfig_ = dxml.parser.makeConfig(
        dxml.parser.SkipComments.yes,
        dxml.parser.SkipPI.yes,
        dxml.parser.SplitEmpty.yes,
        dxml.parser.ThrowOnEntityRef.yes
    );
    bool isStAXParser_ = false;
    string fullPath_;
    string fullyQualifiedXmlFilePath_;
    string docText_;
    dxml.dom.DOMEntity!(string) xmlDom_;

// ################################## UNUSED ##################################
//  Adding in case I start using stAX traversal but until that time
// just leaving private out for now.
    dxml.parser.EntityRange!(xmlConfig_, string) xmlStAX_;

    void
    setStAXParser(bool stAXParsing) {
        // Basically this you have to manually parse the XML
        // line by line. Because it's stream based, it's fast and memory
        // efficient. Keep it false until you find a need for it. Otherwise
        // dom should do the trick.
        this.isStAXParser_ = stAXParsing;
    }

    bool
    isStAXParser() {
        return this.isStAXParser_;
    }

    dxml.parser.EntityRange!(xmlConfig_, string)
    xmlStAX() {
        // Basically this you have to manually parse the XML
        // line by line. Because it's stream based, it's fast and memory
        // efficient. Keep it false until you find a need for it. Otherwise
        // dom should do the trick.
        return this.xmlStAX_;
    }
// ################################## UNUSED ##################################

    void 
    setDocTextFromFullFilePath() {
        this.docText_ = std.file.readText(fullPath());
    }

    void 
    setDocText(string xmlText) {
        this.docText_ = xmlText;
    }

    string 
    docText() {
        return this.docText_;
    }
    
    void 
    setXml() {
        // Basically read file once. Could become expensive space-wise
        // so may want to change this in the future.

        // NOTE: You need to directly access this.xmlConfig_ because that is a
        //       compile time constant. Accessing via xmlConfig() is runtime and
        //       that is not allowed in templates. You can also just ignore
        //       having the enum private member altogether and just pass it in.
        // if (stAXParser()) {
        //    this.xmlStAX_ = dxml.parser.parseXML!(this.xmlConfig_)(docText());
        // }
        // else {
        this.xmlDom_ = dxml.dom.parseDOM!(this.xmlConfig_)(docText());
        // }
    }
}

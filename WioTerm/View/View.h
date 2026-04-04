// View.h - View class definition for WioTerm

#ifndef VIEW_H
#define VIEW_H

class Model;

class View {
public:
    View();

    void update(const Model& model);
};

#endif // VIEW_H

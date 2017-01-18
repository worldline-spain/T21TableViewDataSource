#T21TableViewDataSource

The TableViewDataSource class is a helper class to manage TableView data manipulations like **additions, deletions** and **updates**. It offers an easy way to update the tableview datasource, **applying a concrete sorting** and **avoiding item duplications** when adding already existing entities into the datasource.

All of this comes with two main features:

* Animation support, which is quite complex for tableviews.
* All the expensive calculations are done in background queues to not impact the main thread.

The following gif shows an example which adds, removes, and updates items randomnly. As we are not using `reloadData` method anymore the tableview can be scrolled while adding/removing/updating items and the scroll is preserved as well without any weird tricks. Nice solution for my *lazy load* table views :D!

Example 1                |  Example 2
:-----------------------:|:-------------------------:
![](doc/Playground.gif)  |   ![](doc/Playground2.gif)


##Version 1.0.0

For the moment this version only offers support for tableviews with only one section. We hope to support multiple sections in a future.

### Setting up a DataSource and configuring its TableView

In order to create a new DataSource class, which may be understood as having a simple Array of items, it's a simple as that.

```

class ViewController: UIViewController {

    let dataSource = TableViewDataSource<DataSourceItem>()
    
    @IBOutlet
    weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.tableView = tableView
    }
    
}

```

The TableViewDataSource is a template class, in this case using the DataSourceItem class type during the constructor specifies the `ItemType` of the internal array. In this case they will be DataSourceItem instances.

```
TableViewDataSource<DataSourceItem>()
```

Later we will see, what's a **DataSourceItem** class, for the moment let's assume that it's a data container class which holds the needed data to present the cells. For example we could have used a simple *Int* or *String* classes. 

```
[DataSourceItem,DataSourceItem,DataSourceItem] or [1,2,3,4,5] or ["a","b","c","d","e"]
```

When we assign a tableView to our dataSource instance, this one sets the tableview delegate and datasource handlers to the dataSource itself. The dataSource class implements the `UITableViewDataSource` and `UITableViewDelegate` protocols.

The UITableView protocol related methods can be easily configured using the following blocks:

```
public var onTableViewDidSetFunction: (_ tableView: UITableView?) -> Void
    
public var cellForRowFunction: (_ tableView: UITableView, _ indexPath: IndexPath, _ item: ItemType) -> (UITableViewCell)
    
public var heightForRowFunction: (_ tableView: UITableView,_ indexPath: IndexPath, _ item: ItemType) -> CGFloat
    
public var didSelectRowFunction: (_ tableView: UITableView,_ indexPath: IndexPath, _ item: ItemType) -> Void
    
public var didDeselectRowFunction: (_ tableView: UITableView,_ indexPath: IndexPath, _ item: ItemType) -> Void
    
public var willSelectRowFunction: (_ tableView: UITableView,_ indexPath: IndexPath, _ item: ItemType) -> IndexPath?
    
public var willDeselectRowFunction: (_ tableView: UITableView,_ indexPath: IndexPath, _ item: ItemType) -> IndexPath?

```

The blocks receive as parameters: 

* the related tableview to avoid retaining it unnecessarily.
* the related row indexPath.
* the `ItemType` instance for this Row (in this case it will be a `DataSourceItem`).

The block `onTableViewDidSetFunction` is executed when the tableview is setted to the DataSource. It's very useful when registering Classes or Nib files for cell identifiers.

Configuring the DataSource using blocks offers the possibility of reusing more code and also provides the possibility of using factory methods to create similar DataSource objects.

In case the blocks are not enough to achieve the desired behaviour, subclassing the DataSource class to add more protocol methods shouldn't be a problem.

### Configuring the cellForRow block

The following code shows how to add a very simple cellForRow block.

```
    
dataSource.cellForRowFunction = { (tableview, indexpath, item) in
    
    var cell = tableview.dequeueReusableCell(withIdentifier: "cell")
    if cell == nil {
        cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
    }
    
    let title = item.value as! String
    cell?.textLabel?.text = title
    return cell!
}
        
```

In this case the DataSourceItem value is cast to String to set the title.

### ItemType generic type

The TableViewDataSource class uses a generic `ItemType` for the internal items. This `ItemType` **must** **implement** the following **protocols**: `DataSourceComparable ` and `Hashable `

```
open class TableViewDataSource<ItemType: Any> : NSObject, UITableViewDataSource, UITableViewDelegate where ItemType: DataSourceComparable, ItemType: Hashable {
	....
}

public protocol DataSourceComparable {
    static func <(lhs: Self, rhs: Self) -> Bool
}

public protocol Hashable : Equatable {

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int { get }
}

```

* *Hashable* is a standard Swift library protocol and it will be used internally to check if an item already exists or it's a new item in the DataSource collection.
* *DataSourceComparable* is a custom protocol which is based on the **less than operator**. It will be used to apply the row sorting.

Each item you add to the DataSource must conform to this protocols. The client can create its own types implementing the protocols, or it can also use the existing container class DataSourceItem.

### The DataSourceItem class

The DataSourceItem class is just a simple wrapper class that already implements the required protocols *Hashable* and *DataSourceComparable*.

```
public class DataSourceItem : DataSourceComparable, Hashable {

    public private(set) var value: Any

    public private(set) var uid: String

    public private(set) var index: Float

    public init(_ value: Any, _ uid: String, _ index: Float = default)
}
```

The main purpose is to offer the possibility to add different types of items into the DataSource using the **Any** value. Of course, we will then have to use a downcast `as!` to access the different types. For example we could have: 

```
// if we want to add this kind of items to the DataSource they should be subclasses of Animal class: 
let items: [Animal] = [Lion(),Elephant(),Zebra()]

//with the DataSourceItem we can have completely different ItemTypes.
let items: [DataSourceItem] =  [DataSourceItem(Lion),DataSourceItem(Train),DataSourceItem(Elephant),DataSourceItem(Plane),DataSourceItem(Zebra),DataSourceItem(Car)]
```

* The DataSourceItem offers a `uid` which is used as **unique id** for the item.
* Also a `Float` **index** value, which is used to apply a concrete **sorting**.

The client is always free to create its own classes, but in most cases DataSourceItem fits the needs of every TableView DataSource.

### Applying a concrete sorting function

By default the DataSource applies the following ascending sorting function:

```
public var sortingFunction: ( _ a: ItemType, _ b: ItemType) -> Bool = { return $0 < $1 }

```
In this case as the ItemTypes implement the DataSourceComparable they are easily compared. The client can set a more complex sorting function.

### Update existing items (by its unique ID)

One of the features of the TableViewDataSource class is the ability to update existing rows/items by its unique identifier. In this example we are adding 3 items (in this case our type will be simple Strings), and then we are updating the first item added with a new title and a new sorting value.

```
let itemA = DataSourceItem("This item is A","itemA",1.0)
let itemB = DataSourceItem("This item is B","itemB",2.0)
let itemC = DataSourceItem("This item is C","itemC",3.0)

self.dataSource.addItems([itemB,itemA,itemC]) // we are adding our items unsorted (B,A,C)

// The resulting table view is sorted automatically to (A,B,C):
// - This item is A
// - This item is B
// - This item is C

```

Now let's update the title of the itemC with "Updated title for C".

```
let newItemC = DataSourceItem("Updated title for C","itemC",3.0)
self.dataSource.addItems([newItemC])

// The resulting table view is updated automatically:
// - This item is A
// - This item is B
// - Updated title for C
```

Now let's update the index (sorting value) for the itemC with 0.5.

```
let newItemC = DataSourceItem("Updated title for C","itemC",0.5)
self.dataSource.addItems([newItemC])

// The resulting table view is sorted automatically:
// - Updated title for C
// - This item is A
// - This item is B

```

The DataSource checks if an item already exists by its `uid` in this case `"itemC"` and updates its values. Remember that the client can create custom classes to apply a different sorting like for example by `Date` or by `String` or by whatever he wants.

### Adding items to the DataSource class

In the previous examples we have seen how to add items to the DataSource, just keep in mind that adding items may involve:

* for the existing items, they will be updated (the cell could be reloaded or if sorting changes created again)
* for the new items, they will be added (creating news cells)

### Removing items from the DataSource class

Removing items it's just as simple as adding them.

```
dataSource.removeItems([DataSourceItem("","itemC")])
```

### DataSource accessors

Clients can ask the datasource instance how many items they have.

```
let count = dataSource.count
```

They can also access using the subscript operator to retrieve internal items.

```
let item4 = dataSource[4]
```

The only way to modify the internal items is through the designated methods.

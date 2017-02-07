//
//  GameCollectionViewController.m
//  Algorithms
//
//  Created by Maxime Boulat on 2/3/17.
//  Copyright © 2017 Maxime Boulat. All rights reserved.
//

#import "GameCollectionViewController.h"
#import "TileCollectionViewCell.h"

@interface GameCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) CGFloat insetValue;
@property (nonatomic, assign) int numberOfItemsAcross;
@property (nonatomic, assign) int datasourceCount;

@property (nonatomic, retain) NSMutableArray <NSMutableArray *> * datasource;

@property (nonatomic, retain) GameTile * startingPoint;
@property (nonatomic, retain) GameTile * goal;

@end


typedef NS_ENUM(NSInteger, Direction) {
	north = 0,
	south,
	east,
	west
};


@implementation GameCollectionViewController 

static NSString * const reuseIdentifier = @"Cell";


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.insetValue = 15;
	self.numberOfItemsAcross = 31;
	
	CGFloat widthOfItem = (self.view.frame.size.width - self.insetValue * 2) / self.numberOfItemsAcross;
	int availableHeight = (self.view.frame.size.height - (2 * self.insetValue));
	int numberOfItemsDeep	= availableHeight / widthOfItem;
	self.datasourceCount = numberOfItemsDeep * self.numberOfItemsAcross;
	
	self.datasource = [NSMutableArray new];
	
	for (int i = 0; i < numberOfItemsDeep;  i++) {
		NSMutableArray * array = [NSMutableArray new];
		for (int l = 0; l < self.numberOfItemsAcross; l++) {
			GameTile * tile = [GameTile new];
			tile.row = i;
			tile.column = l;
			if (i % 2 == 0 || l % 2 == 0) {
				tile.isWall = YES;
			}
			
//			int r = arc4random_uniform(2);
			
			[array addObject:tile];
		}
		[self.datasource addObject:array];
	}
	
//	[self makeMaze];
	//[self doBinarySearch];
	[self doSort];

}

#pragma mark CollectionView methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datasourceCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TileCollectionViewCell *cell = (TileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

	// get row and column
	NSInteger row = indexPath.row / self.numberOfItemsAcross;
	NSInteger column = indexPath.row % self.numberOfItemsAcross;
	
	// get corresponding data item
	
	GameTile * gametile = self.datasource[row][column];
	cell.tileView.backgroundColor = gametile.isWall ? [UIColor lightGrayColor] : [UIColor whiteColor];
	
	if (gametile.isWall) {
		cell.tileView.backgroundColor = [UIColor lightGrayColor];
	}
	else {
		cell.tileView.backgroundColor = [UIColor whiteColor];
	}
	
	switch (gametile.type) {
		case pilot:
			cell.tileView.backgroundColor = [UIColor blueColor];
			break;
		case startingPoint:
			cell.tileView.backgroundColor = [UIColor greenColor];
			break;
		case goal:
			cell.tileView.backgroundColor = [UIColor redColor];
			break;
		default:
			break;
			
	}
	
	
	return cell;
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/


- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	CGFloat width = (self.view.frame.size.width - self.insetValue * 2) / self.numberOfItemsAcross;
	return CGSizeMake(width, width);
}

- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	
	return UIEdgeInsetsMake(self.insetValue, self.insetValue, self.insetValue, self.insetValue);
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	
	return 0;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	
	return 0;
}


#pragma mark Helper methods

- (void) makeMaze {
	

	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		NSInteger currentRow = 1;
		NSInteger currentColumn = 1;
		
		BOOL northChecked = NO;
		BOOL westChecked = NO;
		BOOL southChecked = NO;
		BOOL eastChecked = NO;
		
		NSInteger totalTiles = 0;
		NSInteger tilesVisited = 0;
		
		NSMutableArray * undoStack = [NSMutableArray new];
		
		GameTile * previous;
		
		for (NSMutableArray *column in self.datasource) {
			for (GameTile * tile in column) {
				if (!tile.isWall) {
					totalTiles ++;
				}
			}
		}
		
		while (1) {
			NSInteger currentDirection = arc4random_uniform(4);
			
			switch (currentDirection) {
				case north:
				{
					NSLog(@"Going north");
					// check if two spaces north is available
					
					if (currentRow - 2 <= 0) {
						northChecked = YES;
						NSLog(@"North: Bailing because out of bounds");
					}
					else {
						
						NSInteger newRow = currentRow - 2;
						
						// get the corresponding tile
						GameTile * tile = self.datasource[newRow][currentColumn];
						tile.type = pilot;
						previous.type = none;
						previous = tile;
						if (tile.visited == YES) {
							NSLog(@"North: Bailing because already visited");
							northChecked = YES;
						}
						else {
							
							[undoStack insertObject:self.datasource[currentRow][currentColumn] atIndex:0];
							
							NSLog(@"North: Updating");
							tilesVisited ++;
							// Get the wall, tear it down
							GameTile * wall = self.datasource[currentRow - 1][currentColumn];
							wall.isWall = NO;
							// update tile
							tile.visited = YES;
							currentRow = newRow;
							northChecked = NO;
						}
					}
				}
					break;
				case east:
					
					if (currentColumn + 2 >= self.numberOfItemsAcross) {
						NSLog(@"East: Bailing because out of bounds");
						eastChecked = YES;
					}
					else {
						NSInteger newColumn = currentColumn + 2;
						GameTile * tile = self.datasource[currentRow][newColumn];
						tile.type = pilot;
						previous.type = none;
						previous = tile;
						if (tile.visited) {
							NSLog(@"East: Bailing because already visited");
							eastChecked = YES;
						}
						else {
							
							[undoStack insertObject:self.datasource[currentRow][currentColumn] atIndex:0];
							
							NSLog(@"East: Updating");
							tilesVisited ++;
							// Get the wall, tear it down
							GameTile * wall = self.datasource[currentRow][currentColumn + 1];
							wall.isWall = NO;
							// update tile
							tile.visited = YES;
							currentColumn = newColumn;
							eastChecked = NO;
						}
					}
					break;
				case south:
				{
					// check if two spaces north is available
					
					if (currentRow + 2 >= self.datasource.count) {
						NSLog(@"South: Bailing because out of bounds");
						southChecked = YES;
					}
					else {
						NSInteger newRow = currentRow + 2;
						
						// get the corresponding tile
						GameTile * tile = self.datasource[newRow][currentColumn];
						tile.type = pilot;
						previous.type = none;
						previous = tile;
						if (tile.visited == YES) {
							NSLog(@"South: Bailing because already visited");
							southChecked = YES;
						}
						else {
							
							[undoStack insertObject:self.datasource[currentRow][currentColumn] atIndex:0];
							
							NSLog(@"South: Updating");
							tilesVisited ++;
							// Get the wall, tear it down
							GameTile * wall = self.datasource[currentRow + 1][currentColumn];
							wall.isWall = NO;
							// update tile
							tile.visited = YES;
							currentRow = newRow;
							southChecked = NO;
						}
					}
				}
					break;
				case west:
					if (currentColumn - 2 <= 0) {
						NSLog(@"West: Bailing because out of bounds");
						westChecked = YES;
					}
					else {
						NSInteger newColumn = currentColumn - 2;
						GameTile * tile = self.datasource[currentRow][newColumn];
						tile.type = pilot;
						previous.type = none;
						previous = tile;
						if (tile.visited) {
							NSLog(@"West: Bailing because already visited");
							westChecked = YES;
						}
						else {
							
							[undoStack insertObject:self.datasource[currentRow][currentColumn] atIndex:0];
							
							NSLog(@"West: Updating");
							tilesVisited ++;
							// Get the wall, tear it down
							GameTile * wall = self.datasource[currentRow][currentColumn - 1];
							wall.isWall = NO;
							// update tile
							tile.visited = YES;
							currentColumn = newColumn;
							westChecked = NO;
						}
					}
					break;
			}
			
			NSLog(@"Tiles visited = %li totalTiles = %li", (long) tilesVisited, (long) totalTiles);
			
			if (northChecked && southChecked && eastChecked && westChecked) {
				
				NSLog(@"Dead end, backing out with %li", (long) undoStack.count);
				
				GameTile * previous = undoStack[0];
				[undoStack removeObjectAtIndex:0];
				currentColumn = previous.column;
				currentRow = previous.row;
				northChecked = NO;
				southChecked = NO;
				westChecked = NO;
				eastChecked = NO;
			}
			
			dispatch_sync(dispatch_get_main_queue(), ^{
				[self.collectionView reloadData];
			});
			
//			[NSThread sleepForTimeInterval:0.5];
			
			if (tilesVisited >= totalTiles) {
				previous.type = none;
				break;
			}
		}
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self setMarkers];
		});
	});
	


}

- (void) setMarkers {
	
	// pick random row and column for start until you get an empty tile
	
	NSInteger randomRow = arc4random_uniform((int)self.datasource.count);
	NSInteger randomColumn = arc4random_uniform(self.numberOfItemsAcross);
	GameTile * tile = self.datasource[randomRow][randomColumn];
	
	while (tile.isWall) {
		randomRow = arc4random_uniform((int)self.datasource.count);
		randomColumn = arc4random_uniform(self.numberOfItemsAcross);
		tile = self.datasource[randomRow][randomColumn];
	}
	
	tile.type = startingPoint;
	self.startingPoint = tile;
	
	[self.collectionView reloadData];
	
	// pick random row and column for goal until you get an empty tile
	
	randomRow = arc4random_uniform((int)self.datasource.count);
	randomColumn = arc4random_uniform(self.numberOfItemsAcross);
	tile = self.datasource[randomRow][randomColumn];
	
	while (tile.isWall) {
		randomRow = arc4random_uniform((int)self.datasource.count);
		randomColumn = arc4random_uniform(self.numberOfItemsAcross);
		tile = self.datasource[randomRow][randomColumn];
	}
	
	tile.type = goal;
	self.goal = tile;
	[self.collectionView reloadData];
	
}

- (void) findpath {
	
	// lets mark all the squares with a score until we reach the goal.
	NSInteger row = self.goal.row;
	NSInteger column = self.goal.column;
	
	// Now lets explore every possible path
	
	
	
}

- (void) doBinarySearch {
	
	NSInteger random = arc4random_uniform(100000);
	
	NSMutableArray * array = [NSMutableArray new];
	
	for (int i = 0; i<random; i++) {
		[array addObject:@(i)];
	}
	
	NSLog(@"What is the random: %li and the array count: %li", random, array.count);
	
	NSInteger target = arc4random_uniform(array.count);
	
	NSInteger min = 0;
	NSInteger max = array.count - 1;
	
	while (1) {
		NSInteger middle = (max + min) / 2;
		NSInteger guess = ((NSNumber *)array[middle]).intValue;
		
		NSLog(@"guess: %li, target: %li, min: %li, max: %li", guess, target, min, max);
		
		if (guess == target) {
			NSLog(@"Found it! Breaking");
			break;
		}
		else if (guess > target){
			max = guess - 1;
		}
		else {
			min = guess + 1;
		}
	}
}


- (void) doSort {
	
	NSMutableArray * array = @[@"Kevin",
							   @"John",
							   @"Amy",
							   @"Britney",
							   @"Marc",
							   @"Joseph",
							   @"Mike",
							   @"Dan",
							   @"Dave",
							   @"Eric",
							   @"Ann",
							   @"Mary"];
	
	
	
	
	// First method (using compare:)
	
	NSArray * sortedArray1 = [array sortedArrayUsingSelector:@selector(compare:)];
	

	// Second method (using sort descriptors)
	
	NSArray * dates = [self makeArrayOfDates];
	NSMutableArray * array2 = [NSMutableArray new];
	
	for (int i = 0; i<dates.count ; i++) {
		NSDate * date = dates[i];
		NSString * name = array[i];
		
		Person * person = [[Person alloc]initWithDate:date andName:name];
		[array2 addObject:person];
	}
	
	NSSortDescriptor * descriptors = [[NSSortDescriptor alloc]initWithKey:@"birthDate" ascending:YES];
	NSArray * sortedArray2 = [array2 sortedArrayUsingDescriptors:@[descriptors]];
	
	
//	for (Person * person in sortedArray2) {
//		NSLog(@"this is the date: %@", person.birthDate);
//	}
	
	// Third method (implementing compare)
	
	NSArray * sortedArray3 = [array2 sortedArrayUsingSelector:@selector(compare:)];
	
	for (Person * person in sortedArray3) {
		NSLog(@"this is the date: %@", person.birthDate);
	}
	
	// Fourth method (using a block)
	
	NSArray * sortedArray4 = [array2 sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
		
		Person * person1 = (Person *) obj1;
		Person * person2 = (Person *) obj2;
		
		return [person1 compare: person2];
	}];
	
//	for (Person * person in sortedArray4) {
//		NSLog(@"this is the date: %@", person.birthDate);
//	}
	
	
	// Location sort
	
	NSMutableArray * newArray = [@[]mutableCopy];
	NSDate * referenceDate = [NSDate date];
	Person * youngestPerson;
	
	while (array2.count) {
		
		int counter = 0;
		
		for (Person * person in array2) {
			counter ++;

		}
		
		
		for (int i = 0; i < array2.count; i++) {
			Person * person = array2[i];
			NSLog(@"Person is %@, reference date is: %@", person.firstName, referenceDate);
			if ([person.birthDate compare:referenceDate] == NSOrderedAscending) {
				NSLog(@"test passed");
				youngestPerson = person;
				referenceDate = person.birthDate;
			}
		}
		
		[newArray addObject:youngestPerson];
		[array2 removeObject:youngestPerson];
		
		NSLog(@"Removing this person: %@", youngestPerson.firstName);

		referenceDate = [NSDate date];
	
	}
	
	
	for (Person * person in newArray) {
		NSLog(@"enumerating person with date: %@", person.birthDate);
	}
	

	
	
}

- (NSArray *) makeArrayOfDates {
	
	NSMutableArray * dates = [NSMutableArray new];
	
	NSDateComponents * components = [[NSDateComponents alloc]init];
	components.day = 23;
	components.month = 10;
	components.year = 1980;
	
	NSDate * birthdate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[dates addObject:birthdate];
	
	components = [[NSDateComponents alloc]init];
	components.day = 12;
	components.month = 3;
	components.year = 1962;
	
	birthdate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[dates addObject:birthdate];
	
	components = [[NSDateComponents alloc]init];
	components.day = 21;
	components.month = 7;
	components.year = 1986;
	
	birthdate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[dates addObject:birthdate];
	
	components = [[NSDateComponents alloc]init];
	components.day = 24;
	components.month = 3;
	components.year = 1981;
	
	birthdate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[dates addObject:birthdate];
	
	components = [[NSDateComponents alloc]init];
	components.day = 17;
	components.month = 8;
	components.year = 1964;
	
	birthdate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[dates addObject:birthdate];
	
	components = [[NSDateComponents alloc]init];
	components.day = 17;
	components.month = 8;
	components.year = 1964;
	
	birthdate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[dates addObject:birthdate];
	
	components = [[NSDateComponents alloc]init];
	components.day = 9;
	components.month = 8;
	components.year = 1962;
	
	birthdate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[dates addObject:birthdate];
	
	components = [[NSDateComponents alloc]init];
	components.day = 25;
	components.month = 7;
	components.year = 1988;
	
	birthdate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[dates addObject:birthdate];
	
	components = [[NSDateComponents alloc]init];
	components.day = 11;
	components.month = 4;
	components.year = 1987;
	
	birthdate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[dates addObject:birthdate];
	
	components = [[NSDateComponents alloc]init];
	components.day = 25;
	components.month = 12;
	components.year = 1982;
	
	birthdate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[dates addObject:birthdate];
	
	components = [[NSDateComponents alloc]init];
	components.day = 2;
	components.month = 5;
	components.year = 1981;
	
	birthdate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[dates addObject:birthdate];
	
	components = [[NSDateComponents alloc]init];
	components.day = 17;
	components.month = 10;
	components.year = 1983;
	
	birthdate = [[NSCalendar currentCalendar] dateFromComponents:components];
	[dates addObject:birthdate];
	
	return [dates copy];
	
}

@end


@implementation GameTile


- (instancetype)init
{
	self = [super init];
	if (self) {
		self.isWall = NO;
		self.visited = NO;
		self.type = none;
	}
	return self;
}

@end

@implementation Person

- (instancetype)initWithDate: (NSDate *) date andName: (NSString *) name
{
	self = [super init];
	if (self) {
		self.birthDate = date;
		self.firstName = name;
	}
	return self;
}

- (NSComparisonResult)compare:(id)other
{
	
	if ([self.birthDate compare: ((Person *)other).birthDate] == NSOrderedDescending) {
		return NSOrderedDescending;
	}
	else if ([self.birthDate compare: ((Person *)other).birthDate] == NSOrderedAscending) {
		return NSOrderedAscending;
	}
	else {
		return NSOrderedSame;
	}
}


@end

//
//  LevelGenerator.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 07/05/26.
//

import CoreGraphics
import GameplayKit

struct GeneratedPlatform {
    let position: CGPoint
    let textureName: String
}

struct GeneratedLevel {
    let platforms: [GeneratedPlatform]
    let startPositions: [CGPoint]
}

class LevelGenerator {
    private struct PlatformCell {
        let column: Int
        let row: Int
        let offsetX: CGFloat
        let offsetY: CGFloat
    }
    
    private struct CellKey: Hashable {
        let column: Int
        let row: Int
    }
    
    private let config: LevelConfig
    private let randomSource: GKLinearCongruentialRandomSource
    
    private var occupiedCells = Set<CellKey>()
    private let safeMinColumn: Int = 1
    private var safeMaxColumn: Int {
        config.gridColumns - 2
    }
    
    init(config: LevelConfig, seed: UInt64) {
        self.config = config
        self.randomSource = GKLinearCongruentialRandomSource(seed: seed)
    }
    
    func generate() -> GeneratedLevel {
        occupiedCells.removeAll()
        
        var platforms: [GeneratedPlatform] = []
        
        let starts = startingCells()
        let maxRow = config.gridRows - 1
        
        // Add starting platforms
        for start in starts {
            if let platform = createPlatform(from: start) {
                platforms.append(platform)
                occupiedCells.insert(key(for: start))
            }
        }
        
        // Generate upward route from each starting platform
        for start in starts {
            var previous = start
            
            while previous.row < maxRow {
                guard let main = generateReachableCell(
                    from: previous
                ) else {
                    break
                }
                
                if main.row > maxRow {
                    break
                }
                
                if let platform = createPlatform(from: main) {
                    platforms.append(platform)
                    occupiedCells.insert(key(for: main))
                }
                
                if config.isBranchEnabled {
                    let progress = CGFloat(main.row) / CGFloat(config.gridRows)
                    
                    if let branch = maybeGenerateBranch(from: previous, main: main, progress: progress) {
                        if let branchPlatform = createPlatform(from: branch) {
                            platforms.append(branchPlatform)
                            occupiedCells.insert(key(for: branch))
                        }
                    }
                }
                
                previous = main
            }
        }
        
        let playerHalfHeight: CGFloat = 32 // 64x64 (player's size)
        let floorTopY = config.startY + config.floorSize.height / 2
        
        // Players' start positions
        let startPositions = [
            CGPoint(
                x: config.mapWidth / 2,
                y: floorTopY + playerHalfHeight + 2
            )
        ]
        
        return GeneratedLevel(
            platforms: platforms,
            startPositions: startPositions
        )
    }
    
    // MARK: - Grid
    private var gridCellWidth: CGFloat {
        config.mapWidth / CGFloat(config.gridColumns)
    }
    
    private var gridRowHeight: CGFloat {
        config.finishLineY / CGFloat(config.gridRows + 2)
    }
    
    private func makeCell(column: Int, row: Int) -> PlatformCell {
        PlatformCell(
            column: clamp(column, min: safeMinColumn, max: safeMaxColumn),
            row: row,
            offsetX: nextRandom(in: -30...30),
            offsetY: nextRandom(in: -8...8)
        )
    }
    
    private func makeStartCell(column: Int, row: Int) -> PlatformCell {
        PlatformCell(
            column: clamp(column, min: safeMinColumn, max: safeMaxColumn),
            row: row,
            offsetX: nextRandom(in: -30...30),
            offsetY: nextRandom(in: -8...8)
        )
    }
    
    private func key(for cell: PlatformCell) -> CellKey {
        CellKey(column: cell.column, row: cell.row)
    }
    
    private func worldPosition(for cell: PlatformCell) -> CGPoint {
        let x = CGFloat(cell.column) * gridCellWidth + gridCellWidth / 2 + cell.offsetX
        let y = config.startY + CGFloat(cell.row) * gridRowHeight + cell.offsetY
        return CGPoint(x: x, y: y)
    }
    
    private func isCellFree(_ cell: PlatformCell) -> Bool {
        guard cell.column >= 0, cell.column < config.gridColumns else  { return false }
        guard cell.row >= 0, cell.row < config.gridRows else { return false }
        return !occupiedCells.contains(key(for: cell))
    }
    
    private func startingCells() -> [PlatformCell] {
        let startCount = 2
        let row = 1
        
        var result: [PlatformCell] = []
        let startFractions: [CGFloat] = [0.25, 0.75]
        
        for index in 0..<startCount {
            let baseColumn = Int((CGFloat(config.gridColumns - 1) * startFractions[index]).rounded())
            let randomOffset = nextRandomInt(-1...1)
            
            let column = clamp(
                baseColumn + randomOffset,
                min: safeMinColumn,
                max: safeMaxColumn
            )
            
            let startCell = makeCell(column: column, row: row)
            
            // DEBUG
            let position = worldPosition(for: startCell)
            print("""
            START platform:
            column: \(startCell.column), row: \(startCell.row)
            x: \(Int(position.x)), y: \(Int(position.y))
            offsetX: \(Int(startCell.offsetX)), offsetY: \(Int(startCell.offsetY))
            """)
            
            result.append(startCell)
        }
        
        return result.sorted { $0.column < $1.column }
    }
    
    private func routeColumnRange(for index: Int, total: Int) -> ClosedRange<Int> {
        let columnsPerRoute = CGFloat(config.gridColumns) / CGFloat(total)
        
        let rawMin = Int(floor(CGFloat(index) * columnsPerRoute))
        let rawMax = Int(ceil(CGFloat(index + 1) * columnsPerRoute)) - 1
        
        // Allow neighbouring sections to overlap slightly
        let overlap = 1
        
        let minColumn = clamp(
            rawMin - overlap,
            min: safeMinColumn,
            max: safeMaxColumn
        )
        let maxColumn = clamp(
            rawMax + overlap,
            min: minColumn,
            max: safeMaxColumn
        )
        
        return minColumn...maxColumn
    }
    
    private func baseRouteColumnRange(for index: Int, total: Int) -> ClosedRange<Int>{
        let columnsPerRoute = CGFloat(config.gridColumns) / CGFloat(total)
        
        let rawMin = Int(floor(CGFloat(index) * columnsPerRoute))
        let rawMax = Int(ceil(CGFloat(index + 1) * columnsPerRoute)) - 1
        
        let minColumn = clamp(
            rawMin,
            min: safeMinColumn,
            max: safeMaxColumn
        )
        let maxColumn = clamp(
            rawMax,
            min: minColumn,
            max: safeMaxColumn
        )
        
        return minColumn...maxColumn
    }
    
    private func chooseColumnMove(from column: Int) -> Int {
        
        if column <= safeMinColumn {
            return 1
        }
        
        if column >= safeMaxColumn {
            return -1
        }
        
        return nextRandom(in: 0...1) < 0.5 ? -1 : 1
    }
    
    // MARK: - Reachability
    private func isReachable(from previous: PlatformCell, to next: PlatformCell) -> Bool {
        let rowGap = next.row - previous.row
        
        let previousPosition = worldPosition(for: previous)
        let nextPosition = worldPosition(for: next)
        
        let dx = abs(nextPosition.x - previousPosition.x)
        
        if rowGap == 0 {
            return dx <= gridCellWidth * 2.0
        }
        
        if rowGap == 1 {
            return dx <= gridCellWidth * 1.5
        }
        
        return false
    }
    
    // MARK: - Generation
    
    private func generateReachableCell(from previous: PlatformCell) -> PlatformCell? {
        for _ in 0..<40 {
            let candidate = generateNextCell(from: previous)
            
            if isReachable(from: previous, to: candidate), isCellFree(candidate) {
                return candidate
            }
        }
        
        let fallbackOffsets = fallbackOffsetsForColumn(previous.column)
        
        for offset in fallbackOffsets {
            let fallbackColumn = clamp(
                previous.column + offset,
                min: safeMinColumn,
                max: safeMaxColumn
            )
            let fallback = makeCell(
                column: fallbackColumn,
                row: previous.row + 1
            )
            
            if isReachable(from: previous, to: fallback), isCellFree(fallback) {
                return fallback
            }
        }
        
        return nil
    }
    
    private func generateNextCell(from previous: PlatformCell) -> PlatformCell {
        let rowGap = 1
        
        let colMove = chooseColumnMove(from: previous.column)
        
        var column = clamp(
            previous.column + colMove,
            min: safeMinColumn,
            max: safeMaxColumn
        )
        
        // Try opposite direction if clamping create new platform in same column as previous
        if column == previous.column {
            column = clamp(
                previous.column - colMove,
                min: safeMinColumn,
                max: safeMaxColumn
            )
        }
        
        return makeCell(
            column: column,
            row: previous.row + rowGap
        )
    }
    
    private func maybeGenerateBranch(
        from previous: PlatformCell,
        main: PlatformCell,
        progress: CGFloat
    ) -> PlatformCell? {
        let branchChance = lerp(8, 3, progress)
        
        guard nextRandom(in: 0...100) < branchChance else {
            return nil
        }
        
        for _ in 0..<15 {
            let side = nextRandom(in: 0...1) < 0.5 ? -1 : 1
            let colOffset = nextRandomInt(1...2) * side
            let rowOffset = nextRandom(in: 0...100) < 85 ? 0 : 1
            
            let branchColumn = clamp(
                main.column + colOffset,
                min: safeMinColumn,
                max: safeMaxColumn
            )
            
            let candidate = makeCell(
                column: branchColumn,
                row: main.row + rowOffset
            )
            
            let reachableFromPrevious = isReachable(from: previous, to: candidate)
            let reachableFromMain = isReachable(from: main, to: candidate)
            
            if isCellFree(candidate), reachableFromPrevious || reachableFromMain {
                return candidate
            }
        }
        
        return nil
    }
    
    private func createPlatform(from cell: PlatformCell) -> GeneratedPlatform? {
        guard isCellFree(cell)  else { return nil }
        
        let position = worldPosition(for: cell)
        
        // DEBUG
        print("""
        Platform generated:
        column: \(cell.column), row: \(cell.row)
        x: \(Int(position.x)), y: \(Int(position.y))
        offsetX: \(Int(cell.offsetX)), offsetY: \(Int(cell.offsetY))
        """)
        
        return GeneratedPlatform(
            position: position,
            textureName: "PlatformEarth"
        )
    }
    
    private func fallbackOffsetsForColumn(_ column: Int) -> [Int] {
        if column <= safeMinColumn {
            return [1, 0]
        }
        
        if column >= safeMaxColumn {
            return [-1, 0]
        }
        
        return [-1, 1, 0]
    }
    
    // MARK: - Random Helpers
    private func nextRandom(in range: ClosedRange<CGFloat>) -> CGFloat {
        let f = randomSource.nextUniform()
        return range.lowerBound + CGFloat(f) * (range.upperBound - range.lowerBound)
    }
    
    private func nextRandomInt(_ range: ClosedRange<Int>) -> Int {
        let lower = range.lowerBound
        let upper = range.upperBound
        guard upper >= lower else { return lower }
        
        let count = upper - lower + 1
        return lower + randomSource.nextInt(upperBound: count)
    }
    
    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * min(max(t, 0), 1)
    }
    
    private func clamp(_ value: Int, min minValue: Int, max maxValue: Int) -> Int {
        Swift.min(Swift.max(value, minValue), maxValue)
    }
}
